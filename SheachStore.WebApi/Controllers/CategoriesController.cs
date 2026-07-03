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
public class CategoriesController : ControllerBase
{
    private readonly IRepository<Category> _repository;
    private readonly AppDbContext _dbContext;

    public CategoriesController(IRepository<Category> repository, AppDbContext dbContext)
    {
        _repository = repository;
        _dbContext = dbContext;
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
        var slugExists = await _dbContext.Categories.AnyAsync(c => c.Slug == request.Slug, cancellationToken);
        if (slugExists)
        {
            return Conflict("A category with this slug already exists.");
        }

        var nameExists = await _dbContext.Categories.AnyAsync(
            c => c.Name.ToLower() == request.Name.ToLower(), cancellationToken);
        if (nameExists)
        {
            return Conflict($"A category with the name '{request.Name}' already exists.");
        }

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

        var slugExists = await _dbContext.Categories.AnyAsync(c => c.Slug == request.Slug && c.Id != id, cancellationToken);
        if (slugExists)
        {
            return Conflict("A category with this slug already exists.");
        }

        var nameExists = await _dbContext.Categories.AnyAsync(
            c => c.Name.ToLower() == request.Name.ToLower() && c.Id != id, cancellationToken);
        if (nameExists)
        {
            return Conflict($"A category with the name '{request.Name}' already exists.");
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

        var hasBooks = await _dbContext.Books.AnyAsync(b => b.CategoryId == id, cancellationToken);
        if (hasBooks)
        {
            return BadRequest("Cannot delete this category because it has associated books.");
        }

        _repository.Remove(category);
        await _repository.SaveChangesAsync(cancellationToken);

        return NoContent();
    }
}
