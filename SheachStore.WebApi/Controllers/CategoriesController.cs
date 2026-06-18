using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SheachStore.WebApi.Dtos;
using SheachStore.WebApi.Models;
using SheachStore.WebApi.Repositories;

namespace SheachStore.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoriesController : ControllerBase
{
    private readonly IRepository<Category> _repository;

    public CategoriesController(IRepository<Category> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<List<CategoryResponse>>> GetAll(CancellationToken cancellationToken)
    {
        var categories = await _repository.GetAllAsync(cancellationToken);
        return Ok(categories.Select(category => category.ToResponse()));
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<CategoryResponse>> GetById(int id, CancellationToken cancellationToken)
    {
        var category = await _repository.GetByIdAsync(id, cancellationToken);
        return category is null ? NotFound() : Ok(category.ToResponse());
    }

    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult<CategoryResponse>> Create(CategoryRequest request, CancellationToken cancellationToken)
    {
        var category = new Category { Name = request.Name, Slug = request.Slug };
        await _repository.AddAsync(category, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return CreatedAtAction(nameof(GetById), new { id = category.Id }, category.ToResponse());
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, CategoryRequest request, CancellationToken cancellationToken)
    {
        var category = await _repository.GetByIdAsync(id, cancellationToken);
        if (category is null)
        {
            return NotFound();
        }

        category.Name = request.Name;
        category.Slug = request.Slug;
        _repository.Update(category);
        await _repository.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        var category = await _repository.GetByIdAsync(id, cancellationToken);
        if (category is null)
        {
            return NotFound();
        }

        _repository.Remove(category);
        await _repository.SaveChangesAsync(cancellationToken);

        return NoContent();
    }
}
