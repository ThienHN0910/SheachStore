using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SheachStore.WebApi.Dtos;
using SheachStore.WebApi.Models;
using SheachStore.WebApi.Repositories;

namespace SheachStore.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthorsController : ControllerBase
{
    private readonly IRepository<Author> _repository;

    public AuthorsController(IRepository<Author> repository)
    {
        _repository = repository;
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

        _repository.Remove(author);
        await _repository.SaveChangesAsync(cancellationToken);

        return NoContent();
    }
}
