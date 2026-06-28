using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SheachStore.WebApi.Data;
using SheachStore.WebApi.Dtos;
using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class WishlistController : ControllerBase
{
    private readonly AppDbContext _dbContext;

    public WishlistController(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<BookResponse>>> GetMine(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        var books = await _dbContext.WishlistItems
            .AsNoTracking()
            .Where(item => item.UserId == userId)
            .Include(item => item.Book)
                .ThenInclude(book => book!.Author)
            .Include(item => item.Book)
                .ThenInclude(book => book!.Category)
            .Select(item => item.Book)
            .ToListAsync(cancellationToken);

        return Ok(books.Where(b => b != null).Select(b => b!.ToResponse()));
    }

    [HttpPost]
    public async Task<ActionResult> Add(WishlistRequest request, CancellationToken cancellationToken)
    {
        var bookExists = await _dbContext.Books.AnyAsync(b => b.Id == request.BookId, cancellationToken);
        if (!bookExists)
        {
            return BadRequest("Book does not exist.");
        }

        var userId = GetUserId();
        var exists = await _dbContext.WishlistItems
            .AnyAsync(item => item.UserId == userId && item.BookId == request.BookId, cancellationToken);
        
        if (exists)
        {
            return Ok(); // Already in wishlist, treat as success
        }

        var item = new WishlistItem
        {
            UserId = userId,
            BookId = request.BookId,
            CreatedAt = DateTime.UtcNow
        };

        await _dbContext.WishlistItems.AddAsync(item, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return Ok();
    }

    [HttpDelete("{bookId:int}")]
    public async Task<IActionResult> Remove(int bookId, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        var item = await _dbContext.WishlistItems
            .FirstOrDefaultAsync(item => item.UserId == userId && item.BookId == bookId, cancellationToken);

        if (item is null)
        {
            return NotFound();
        }

        _dbContext.WishlistItems.Remove(item);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    [HttpGet("check/{bookId:int}")]
    public async Task<ActionResult<bool>> Check(int bookId, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        var exists = await _dbContext.WishlistItems
            .AnyAsync(item => item.UserId == userId && item.BookId == bookId, cancellationToken);
        
        return Ok(exists);
    }

    private string GetUserId()
    {
        return User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new InvalidOperationException("Authenticated user id was not found.");
    }
}
