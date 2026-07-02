using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Dtos;

public static class MappingExtensions
{
    public static UserResponse ToResponse(this User user)
    {
        return new UserResponse(
            user.Id,
            user.Email ?? string.Empty,
            user.FullName,
            user.Role,
            user.LoyaltyPoints,
            user.CreatedAt);
    }

    public static CategoryResponse ToResponse(this Category category)
    {
        return new CategoryResponse(category.Id, category.Name, category.Slug);
    }

    public static AuthorResponse ToResponse(this Author author)
    {
        return new AuthorResponse(author.Id, author.Name, author.Bio);
    }

    public static BookResponse ToResponse(this Book book)
    {
        return new BookResponse(
            book.Id,
            book.Title,
            book.AuthorId,
            book.Author?.Name,
            book.CategoryId,
            book.Category?.Name,
            book.Price,
            book.Stock,
            book.CoverUrl,
            book.Description);
    }

    public static OrderResponse ToResponse(this Order order)
    {
        return new OrderResponse(
            order.Id,
            order.UserId,
            order.User?.FullName,
            order.TotalAmount,
            order.Status,
            order.ShippingAddress,
            order.CreatedAt,
            order.OrderItems.Select(item => new OrderItemResponse(
                item.Id,
                item.BookId,
                item.Book?.Title,
                item.Quantity,
                item.UnitPrice,
                item.Quantity * item.UnitPrice)).ToList());
    }

    public static ReviewResponse ToResponse(this Review review)
    {
        return new ReviewResponse(
            review.Id,
            review.UserId,
            review.User?.FullName,
            review.BookId,
            review.Book?.Title,
            review.Rating,
            review.Comment,
            review.CreatedAt);
    }

    public static CartResponse ToResponse(this Cart cart)
    {
        var items = cart.CartItems.Select(item => new CartItemResponse(
            item.Id,
            item.BookId,
            item.Book?.Title,
            item.Quantity,
            item.Book?.Price ?? 0,
            item.Quantity * (item.Book?.Price ?? 0))).ToList();

        return new CartResponse(cart.Id, cart.UserId, cart.UpdatedAt, items, items.Sum(item => item.LineTotal));
    }
}
