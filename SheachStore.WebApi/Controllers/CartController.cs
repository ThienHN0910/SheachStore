using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SheachStore.WebApi.Data;
using SheachStore.WebApi.Dtos;
using SheachStore.WebApi.Models;
using SheachStore.WebApi.Repositories;

namespace SheachStore.WebApi.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class CartController : ControllerBase
{
    private readonly AppDbContext _dbContext;
    private readonly ICartRepository _cartRepository;

    public CartController(AppDbContext dbContext, ICartRepository cartRepository)
    {
        _dbContext = dbContext;
        _cartRepository = cartRepository;
    }

    [HttpGet]
    public async Task<ActionResult<CartResponse>> GetMine(CancellationToken cancellationToken)
    {
        var cart = await GetOrCreateCartAsync(cancellationToken);
        return Ok(cart.ToResponse());
    }

    [HttpPost("items")]
    public async Task<ActionResult<CartResponse>> AddItem(CartItemRequest request, CancellationToken cancellationToken)
    {
        var book = await _dbContext.Books.FirstOrDefaultAsync(item => item.Id == request.BookId, cancellationToken);
        if (book is null)
        {
            return BadRequest("Book does not exist.");
        }

        if (book.Stock < request.Quantity)
        {
            return BadRequest("Not enough stock.");
        }

        var cart = await GetOrCreateCartAsync(cancellationToken);
        var cartItem = cart.CartItems.FirstOrDefault(item => item.BookId == request.BookId);
        if (cartItem is null)
        {
            cart.CartItems.Add(new CartItem
            {
                BookId = request.BookId,
                Quantity = request.Quantity,
                CreatedAt = DateTime.UtcNow
            });
        }
        else
        {
            if (book.Stock < cartItem.Quantity + request.Quantity)
            {
                return BadRequest("Not enough stock.");
            }

            cartItem.Quantity += request.Quantity;
        }

        cart.UpdatedAt = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);

        var updated = await _cartRepository.GetByUserIdAsync(GetUserId(), cancellationToken);
        return Ok(updated!.ToResponse());
    }

    [HttpPut("items/{itemId:int}")]
    public async Task<IActionResult> UpdateItem(int itemId, UpdateCartItemRequest request, CancellationToken cancellationToken)
    {
        var cart = await GetOrCreateCartAsync(cancellationToken);
        var cartItem = cart.CartItems.FirstOrDefault(item => item.Id == itemId);
        if (cartItem is null)
        {
            return NotFound();
        }

        if (cartItem.Book is not null && cartItem.Book.Stock < request.Quantity)
        {
            return BadRequest("Not enough stock.");
        }

        cartItem.Quantity = request.Quantity;
        cart.UpdatedAt = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    [HttpDelete("items/{itemId:int}")]
    public async Task<IActionResult> RemoveItem(int itemId, CancellationToken cancellationToken)
    {
        var cart = await GetOrCreateCartAsync(cancellationToken);
        var cartItem = cart.CartItems.FirstOrDefault(item => item.Id == itemId);
        if (cartItem is null)
        {
            return NotFound();
        }

        _dbContext.CartItems.Remove(cartItem);
        cart.UpdatedAt = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    [HttpDelete("items")]
    public async Task<IActionResult> Clear(CancellationToken cancellationToken)
    {
        var cart = await GetOrCreateCartAsync(cancellationToken);
        _dbContext.CartItems.RemoveRange(cart.CartItems);
        cart.UpdatedAt = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    private async Task<Cart> GetOrCreateCartAsync(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        var cart = await _cartRepository.GetByUserIdAsync(userId, cancellationToken);
        if (cart is not null)
        {
            return cart;
        }

        cart = new Cart
        {
            UserId = userId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _dbContext.Carts.AddAsync(cart, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return (await _cartRepository.GetByUserIdAsync(userId, cancellationToken))!;
    }

    private string GetUserId()
    {
        return User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new InvalidOperationException("Authenticated user id was not found.");
    }
}
