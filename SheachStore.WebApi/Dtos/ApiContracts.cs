using System.ComponentModel.DataAnnotations;
using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Dtos;

public record UserResponse(string Id, string Email, string FullName, UserRole Role, int LoyaltyPoints, DateTime CreatedAt);

public record CategoryRequest([Required, MaxLength(120)] string Name, [Required, MaxLength(150)] string Slug);
public record CategoryResponse(int Id, string Name, string Slug);

public record AuthorRequest([Required, MaxLength(150)] string Name, [MaxLength(2000)] string? Bio);
public record AuthorResponse(int Id, string Name, string? Bio);

public record BookRequest(
    [Required, MaxLength(250)] string Title,
    int AuthorId,
    int CategoryId,
    [Range(0, double.MaxValue)] decimal Price,
    [Range(0, int.MaxValue)] int Stock,
    [MaxLength(500)] string? CoverUrl,
    [MaxLength(4000)] string? Description);

public record BookResponse(
    int Id,
    string Title,
    int AuthorId,
    string? AuthorName,
    int CategoryId,
    string? CategoryName,
    decimal Price,
    int Stock,
    string? CoverUrl,
    string? Description);

public record CreateOrderItemRequest(int BookId, [Range(1, int.MaxValue)] int Quantity);

public record CreateOrderRequest(
    [Required, MaxLength(500)] string ShippingAddress,
    [MinLength(1)] List<CreateOrderItemRequest> Items);

public record UpdateOrderStatusRequest(OrderStatus Status);

public record OrderItemResponse(int Id, int BookId, string? BookTitle, int Quantity, decimal UnitPrice, decimal LineTotal);

public record OrderResponse(
    int Id,
    string UserId,
    decimal TotalAmount,
    OrderStatus Status,
    string ShippingAddress,
    DateTime CreatedAt,
    List<OrderItemResponse> Items);

public record PayOsCheckoutResponse(int OrderId, string CheckoutUrl, string? QrCodeUrl);

public record PayOsWebhookRequest(string? Code, string? Desc, PayOsWebhookData? Data, string? Signature);

public record PayOsWebhookData(string? OrderCode, string? Status, decimal? Amount, string? Description);

public record ReviewRequest(
    int BookId,
    [Range(1, 5)] int Rating,
    [MaxLength(2000)] string? Comment);

public record ReviewResponse(
    int Id,
    string UserId,
    string? UserFullName,
    int BookId,
    string? BookTitle,
    int Rating,
    string? Comment,
    DateTime CreatedAt);

public record CartItemRequest(int BookId, [Range(1, int.MaxValue)] int Quantity);
public record UpdateCartItemRequest([Range(1, int.MaxValue)] int Quantity);
public record CartItemResponse(int Id, int BookId, string? BookTitle, int Quantity, decimal UnitPrice, decimal LineTotal);
public record CartResponse(int Id, string UserId, DateTime UpdatedAt, List<CartItemResponse> Items, decimal TotalAmount);

public record WishlistRequest([Required] int BookId);
