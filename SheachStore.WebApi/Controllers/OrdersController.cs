using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SheachStore.WebApi.Data;
using SheachStore.WebApi.Dtos;
using SheachStore.WebApi.Models;
using SheachStore.WebApi.Repositories;
using SheachStore.WebApi.Services;

namespace SheachStore.WebApi.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly AppDbContext _dbContext;
    private readonly IOrderRepository _orderRepository;
    private readonly IPayOsService _payOsService;

    public OrdersController(AppDbContext dbContext, IOrderRepository orderRepository, IPayOsService payOsService)
    {
        _dbContext = dbContext;
        _orderRepository = orderRepository;
        _payOsService = payOsService;
    }

    [Authorize(Roles = "Admin")]
    [HttpGet]
    public async Task<ActionResult<List<OrderResponse>>> GetAll(CancellationToken cancellationToken)
    {
        var orders = await _orderRepository.GetAllWithDetailsAsync(cancellationToken);
        return Ok(orders.Select(order => order.ToResponse()));
    }

    [HttpGet("mine")]
    public async Task<ActionResult<List<OrderResponse>>> GetMine(CancellationToken cancellationToken)
    {
        var orders = await _orderRepository.GetByUserIdAsync(GetUserId(), cancellationToken);
        return Ok(orders.Select(order => order.ToResponse()));
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<OrderResponse>> GetById(int id, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdWithDetailsAsync(id, cancellationToken);
        if (order is null)
        {
            return NotFound();
        }

        if (!IsAdmin() && order.UserId != GetUserId())
        {
            return Forbid();
        }

        return Ok(order.ToResponse());
    }

    [HttpPost("payos")]
    public async Task<ActionResult<PayOsCheckoutResponse>> CreatePayOs(CreateOrderRequest request, CancellationToken cancellationToken)
    {
        if (request.Items.Count == 0)
        {
            return BadRequest("Order must contain at least one item.");
        }

        var bookIds = request.Items.Select(item => item.BookId).Distinct().ToList();
        var books = await _dbContext.Books.Where(book => bookIds.Contains(book.Id)).ToListAsync(cancellationToken);
        if (books.Count != bookIds.Count)
        {
            return BadRequest("One or more books do not exist.");
        }

        await using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);

        var orderItems = new List<OrderItem>();
        foreach (var item in request.Items)
        {
            var book = books.Single(book => book.Id == item.BookId);
            if (book.Stock < item.Quantity)
            {
                return BadRequest($"Book '{book.Title}' does not have enough stock.");
            }

            book.Stock -= item.Quantity;
            orderItems.Add(new OrderItem
            {
                BookId = book.Id,
                Quantity = item.Quantity,
                UnitPrice = book.Price
            });
        }

        var order = new Order
        {
            UserId = GetUserId(),
            ShippingAddress = request.ShippingAddress,
            Status = OrderStatus.Pending,
            CreatedAt = DateTime.UtcNow,
            OrderItems = orderItems,
            TotalAmount = orderItems.Sum(item => item.Quantity * item.UnitPrice)
        };

        await _dbContext.Orders.AddAsync(order, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        var checkout = await _payOsService.CreateCheckoutAsync(
            order.Id,
            order.TotalAmount,
            $"Order #{order.Id}",
            cancellationToken);

        await transaction.CommitAsync(cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = order.Id }, checkout);
    }

    [Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/status")]
    public async Task<IActionResult> UpdateStatus(int id, UpdateOrderStatusRequest request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdWithDetailsAsync(id, cancellationToken);
        if (order is null)
        {
            return NotFound();
        }

        if (order.Status == OrderStatus.Cancelled)
        {
            return BadRequest("Cannot change the status of a cancelled order.");
        }

        if (order.Status == request.Status)
        {
            return NoContent(); // No change
        }

        // Business rules:
        // Pending -> Paid or Cancelled (Allowed)
        // Paid -> Cancelled (Allowed)
        // Paid -> Pending (Forbidden)
        if (order.Status == OrderStatus.Paid && request.Status == OrderStatus.Pending)
        {
            return BadRequest("Cannot change status of a paid order back to pending.");
        }

        if (request.Status == OrderStatus.Cancelled)
        {
            foreach (var item in order.OrderItems)
            {
                if (item.Book is not null)
                {
                    item.Book.Stock += item.Quantity;
                }
            }
        }

        order.Status = request.Status;
        _orderRepository.Update(order);
        await _orderRepository.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdWithDetailsAsync(id, cancellationToken);
        if (order is null)
        {
            return NotFound();
        }

        if (order.Status != OrderStatus.Pending && order.Status != OrderStatus.Cancelled)
        {
            return BadRequest("Cannot delete an order that is not Pending or Cancelled.");
        }

        if (order.Status == OrderStatus.Pending)
        {
            foreach (var item in order.OrderItems)
            {
                if (item.Book is not null)
                {
                    item.Book.Stock += item.Quantity;
                }
            }
        }

        _dbContext.OrderItems.RemoveRange(order.OrderItems);
        _dbContext.Orders.Remove(order);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return NoContent();
    }

    [AllowAnonymous]
    [HttpPost("/api/payos/webhook")]
    public async Task<IActionResult> PayOsWebhook(PayOsWebhookRequest request, CancellationToken cancellationToken)
    {
        if (!_payOsService.VerifyWebhookSignature(request))
        {
            return BadRequest("Invalid PayOS signature.");
        }

        if (!string.Equals(request.Data?.Status, "PAID", StringComparison.OrdinalIgnoreCase))
        {
            return Ok();
        }

        if (!int.TryParse(request.Data?.OrderCode, out var orderId))
        {
            return BadRequest("Invalid order code.");
        }

        var order = await _orderRepository.GetByIdAsync(orderId, cancellationToken);
        if (order is null)
        {
            return NotFound();
        }

        order.Status = OrderStatus.Paid;
        _orderRepository.Update(order);
        await _orderRepository.SaveChangesAsync(cancellationToken);

        // Clear the user's cart after successful payment
        var cart = await _dbContext.Carts.Include(c => c.CartItems)
            .FirstOrDefaultAsync(c => c.UserId == order.UserId, cancellationToken);
        if (cart is not null)
        {
            _dbContext.CartItems.RemoveRange(cart.CartItems);
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

        return Ok();
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
