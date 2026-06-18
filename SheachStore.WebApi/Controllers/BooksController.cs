using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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

    public BooksController(
        IBookRepository bookRepository,
        IRepository<Author> authorRepository,
        IRepository<Category> categoryRepository)
    {
        _bookRepository = bookRepository;
        _authorRepository = authorRepository;
        _categoryRepository = categoryRepository;
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

        _bookRepository.Remove(book);
        await _bookRepository.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    private async Task<bool> RelatedEntitiesExistAsync(int authorId, int categoryId, CancellationToken cancellationToken)
    {
        return await _authorRepository.GetByIdAsync(authorId, cancellationToken) is not null
            && await _categoryRepository.GetByIdAsync(categoryId, cancellationToken) is not null;
    }
}
