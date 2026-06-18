using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SheachStore.WebApi.Data;
using SheachStore.WebApi.Dtos;
using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ReviewsController : ControllerBase
{
    private readonly AppDbContext _dbContext;

    public ReviewsController(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    [HttpGet("book/{bookId:int}")]
    public async Task<ActionResult<List<ReviewResponse>>> GetByBook(int bookId, CancellationToken cancellationToken)
    {
        var reviews = await _dbContext.Reviews
            .AsNoTracking()
            .Include(review => review.User)
            .Include(review => review.Book)
            .Where(review => review.BookId == bookId)
            .OrderByDescending(review => review.CreatedAt)
            .ToListAsync(cancellationToken);

        return Ok(reviews.Select(review => review.ToResponse()));
    }

    [Authorize]
    [HttpPost]
    public async Task<ActionResult<ReviewResponse>> Create(ReviewRequest request, CancellationToken cancellationToken)
    {
        var bookExists = await _dbContext.Books.AnyAsync(book => book.Id == request.BookId, cancellationToken);
        if (!bookExists)
        {
            return BadRequest("Book does not exist.");
        }

        var userId = GetUserId();
        var alreadyReviewed = await _dbContext.Reviews
            .AnyAsync(review => review.BookId == request.BookId && review.UserId == userId, cancellationToken);
        if (alreadyReviewed)
        {
            return Conflict("You already reviewed this book.");
        }

        var review = new Review
        {
            UserId = userId,
            BookId = request.BookId,
            Rating = request.Rating,
            Comment = request.Comment,
            CreatedAt = DateTime.UtcNow
        };

        await _dbContext.Reviews.AddAsync(review, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        var created = await _dbContext.Reviews
            .AsNoTracking()
            .Include(item => item.User)
            .Include(item => item.Book)
            .FirstAsync(item => item.Id == review.Id, cancellationToken);

        return CreatedAtAction(nameof(GetByBook), new { bookId = review.BookId }, created.ToResponse());
    }

    [Authorize]
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, ReviewRequest request, CancellationToken cancellationToken)
    {
        var review = await _dbContext.Reviews.FirstOrDefaultAsync(item => item.Id == id, cancellationToken);
        if (review is null)
        {
            return NotFound();
        }

        if (!IsAdmin() && review.UserId != GetUserId())
        {
            return Forbid();
        }

        var bookExists = await _dbContext.Books.AnyAsync(book => book.Id == request.BookId, cancellationToken);
        if (!bookExists)
        {
            return BadRequest("Book does not exist.");
        }

        var reviewUserId = review.UserId;
        var duplicateReview = await _dbContext.Reviews.AnyAsync(
            item => item.Id != id && item.UserId == reviewUserId && item.BookId == request.BookId,
            cancellationToken);
        if (duplicateReview)
        {
            return Conflict("This user already reviewed this book.");
        }

        review.BookId = request.BookId;
        review.Rating = request.Rating;
        review.Comment = request.Comment;
        await _dbContext.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    [Authorize]
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        var review = await _dbContext.Reviews.FirstOrDefaultAsync(item => item.Id == id, cancellationToken);
        if (review is null)
        {
            return NotFound();
        }

        if (!IsAdmin() && review.UserId != GetUserId())
        {
            return Forbid();
        }

        _dbContext.Reviews.Remove(review);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    private string GetUserId()
    {
        return User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new InvalidOperationException("Authenticated user id was not found.");
    }

    private bool IsAdmin()
    {
        return User.IsInRole(UserRole.Admin.ToString());
    }
}
