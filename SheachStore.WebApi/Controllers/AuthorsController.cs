using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SheachStore.WebApi.Data;
using SheachStore.WebApi.Dtos;
using SheachStore.WebApi.Models;
using SheachStore.WebApi.Repositories;
using Microsoft.EntityFrameworkCore;

namespace SheachStore.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthorsController : ControllerBase
{
    private readonly IRepository<Author> _repository;
    private readonly AppDbContext _dbContext;

    public AuthorsController(IRepository<Author> repository, AppDbContext dbContext)
    {
        _repository = repository;
        _dbContext = dbContext;
    }

    [HttpGet]
    public async Task<ActionResult<List<AuthorResponse>>> GetAll(CancellationToken cancellationToken)
    {
        var authors = await _repository.GetAllAsync(cancellationToken);
        return Ok(authors.Select(author => author.ToResponse()));
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<AuthorResponse>> GetById(int id, CancellationToken cancellationToken)
    {
        var author = await _repository.GetByIdAsync(id, cancellationToken);
        return author is null ? NotFound() : Ok(author.ToResponse());
    }

    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult<AuthorResponse>> Create(AuthorRequest request, CancellationToken cancellationToken)
    {
        var exists = await _dbContext.Authors.AnyAsync(
            a => a.Name.ToLower() == request.Name.ToLower(), cancellationToken);
        if (exists)
        {
            return Conflict($"An author with the name '{request.Name}' already exists.");
        }

        var author = new Author { Name = request.Name, Bio = request.Bio };
        await _repository.AddAsync(author, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return CreatedAtAction(nameof(GetById), new { id = author.Id }, author.ToResponse());
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, AuthorRequest request, CancellationToken cancellationToken)
    {
        var author = await _repository.GetByIdAsync(id, cancellationToken);
        if (author is null)
        {
            return NotFound();
        }

        var exists = await _dbContext.Authors.AnyAsync(
            a => a.Name.ToLower() == request.Name.ToLower() && a.Id != id, cancellationToken);
        if (exists)
        {
            return Conflict($"An author with the name '{request.Name}' already exists.");
        }

        author.Name = request.Name;
        author.Bio = request.Bio;
        _repository.Update(author);
        await _repository.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        var author = await _repository.GetByIdAsync(id, cancellationToken);
        if (author is null)
        {
            return NotFound();
        }

        var hasBooks = await _dbContext.Books.AnyAsync(b => b.AuthorId == id, cancellationToken);
        if (hasBooks)
        {
            return BadRequest("Cannot delete this author because they have associated books.");
        }

        _repository.Remove(author);
        await _repository.SaveChangesAsync(cancellationToken);

        return NoContent();
    }
}
