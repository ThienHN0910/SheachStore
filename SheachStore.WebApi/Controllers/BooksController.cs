using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SheachStore.WebApi.Data;
using SheachStore.WebApi.Dtos;
using SheachStore.WebApi.Models;
using SheachStore.WebApi.Repositories;

namespace SheachStore.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly IBookRepository _bookRepository;
    private readonly IRepository<Author> _authorRepository;
    private readonly IRepository<Category> _categoryRepository;
    private readonly AppDbContext _dbContext;

    public BooksController(
        IBookRepository bookRepository,
        IRepository<Author> authorRepository,
        IRepository<Category> categoryRepository,
        AppDbContext dbContext)
    {
        _bookRepository = bookRepository;
        _authorRepository = authorRepository;
        _categoryRepository = categoryRepository;
        _dbContext = dbContext;
    }

    [HttpGet]
    public async Task<ActionResult<List<BookResponse>>> GetAll(CancellationToken cancellationToken)
    {
        var books = await _bookRepository.GetAllWithDetailsAsync(cancellationToken);
        return Ok(books.Select(book => book.ToResponse()));
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<BookResponse>> GetById(int id, CancellationToken cancellationToken)
    {
        var book = await _bookRepository.GetByIdWithDetailsAsync(id, cancellationToken);
        return book is null ? NotFound() : Ok(book.ToResponse());
    }

    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult<BookResponse>> Create(BookRequest request, CancellationToken cancellationToken)
    {
        if (!await RelatedEntitiesExistAsync(request.AuthorId, request.CategoryId, cancellationToken))
        {
            return BadRequest("AuthorId or CategoryId does not exist.");
        }

        var book = new Book
        {
            Title = request.Title,
            AuthorId = request.AuthorId,
            CategoryId = request.CategoryId,
            Price = request.Price,
            Stock = request.Stock,
            CoverUrl = request.CoverUrl,
            Description = request.Description
        };

        await _bookRepository.AddAsync(book, cancellationToken);
        await _bookRepository.SaveChangesAsync(cancellationToken);

        var created = await _bookRepository.GetByIdWithDetailsAsync(book.Id, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = book.Id }, created!.ToResponse());
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, BookRequest request, CancellationToken cancellationToken)
    {
        var book = await _bookRepository.GetByIdAsync(id, cancellationToken);
        if (book is null)
        {
            return NotFound();
        }

        if (!await RelatedEntitiesExistAsync(request.AuthorId, request.CategoryId, cancellationToken))
        {
            return BadRequest("AuthorId or CategoryId does not exist.");
        }

        book.Title = request.Title;
        book.AuthorId = request.AuthorId;
        book.CategoryId = request.CategoryId;
        book.Price = request.Price;
        book.Stock = request.Stock;
        book.CoverUrl = request.CoverUrl;
        book.Description = request.Description;

        _bookRepository.Update(book);
        await _bookRepository.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        var book = await _bookRepository.GetByIdAsync(id, cancellationToken);
        if (book is null)
        {
            return NotFound();
        }

        var hasOrders = await _dbContext.OrderItems.AnyAsync(oi => oi.BookId == id, cancellationToken);
        if (hasOrders)
        {
            return BadRequest("Cannot delete this book because it has order history. Please set its stock to 0 to make it unavailable instead.");
        }

        var reviews = await _dbContext.Reviews.Where(r => r.BookId == id).ToListAsync(cancellationToken);
        _dbContext.Reviews.RemoveRange(reviews);

        var wishlists = await _dbContext.WishlistItems.Where(wi => wi.BookId == id).ToListAsync(cancellationToken);
        _dbContext.WishlistItems.RemoveRange(wishlists);

        var cartItems = await _dbContext.CartItems.Where(ci => ci.BookId == id).ToListAsync(cancellationToken);
        _dbContext.CartItems.RemoveRange(cartItems);

        _bookRepository.Remove(book);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    private async Task<bool> RelatedEntitiesExistAsync(int authorId, int categoryId, CancellationToken cancellationToken)
    {
        return await _authorRepository.GetByIdAsync(authorId, cancellationToken) is not null
            && await _categoryRepository.GetByIdAsync(categoryId, cancellationToken) is not null;
    }
}
