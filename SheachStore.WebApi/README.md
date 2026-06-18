# SheachStore.WebApi

ASP.NET Core .NET 8 WebApi cho bookstore, dùng Entity Framework Core, SQL Server, ASP.NET Core Identity và JWT.

## Cấu hình

Connection string mặc định nằm trong `appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=(localdb)\\MSSQLLocalDB;Database=SheachStoreDb;Trusted_Connection=True;TrustServerCertificate=True"
}
```

JWT dùng các khóa `Jwt:Key`, `Jwt:Issuer`, `Jwt:Audience`. Khi chạy production, thay `Jwt:Key` bằng secret riêng và lưu qua user secrets hoặc biến môi trường.

## Package chính

- `Microsoft.EntityFrameworkCore.SqlServer`
- `Microsoft.EntityFrameworkCore.Design`
- `Microsoft.AspNetCore.Identity.EntityFrameworkCore`
- `Microsoft.AspNetCore.Authentication.JwtBearer`
- `Swashbuckle.AspNetCore`

## Entity và quan hệ

- `User : IdentityUser`: có `FullName`, `Role`, `LoyaltyPoints`, `CreatedAt`; liên kết `Orders`, `Reviews`, `Cart`.
- `Author 1-N Book`
- `Category 1-N Book`, `Category.Slug` unique.
- `User 1-N Order`
- `Order 1-N OrderItem`
- `Book 1-N OrderItem`
- `User 1-N Review`
- `Book 1-N Review`
- `User 1-1 Cart`
- `Cart 1-N CartItem`
- `Book 1-N CartItem`

`AppDbContext` cấu hình enum dạng string, decimal precision cho tiền, unique review theo `(UserId, BookId)`, unique cart theo `UserId`, và `DeleteBehavior.Restrict` ở các quan hệ dễ tạo cascade loop trên SQL Server. Riêng `Cart -> CartItems` dùng cascade vì đây là dependent collection an toàn.

## Endpoint chính

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/books`, `GET /api/books/{id}`, `POST/PUT/DELETE /api/books`
- `GET /api/categories`, `POST/PUT/DELETE /api/categories`
- `GET /api/authors`, `POST/PUT/DELETE /api/authors`
- `GET /api/orders`, `GET /api/orders/mine`, `POST /api/orders`, `PATCH /api/orders/{id}/status`
- `GET /api/reviews/book/{bookId}`, `POST/PUT/DELETE /api/reviews`
- `GET /api/cart`, `POST /api/cart/items`, `PUT /api/cart/items/{itemId}`, `DELETE /api/cart/items/{itemId}`, `DELETE /api/cart/items`

Các endpoint tạo/sửa/xóa dữ liệu catalog yêu cầu role `Admin`. Cart, order và review write yêu cầu JWT.

## Lệnh chạy

```powershell
dotnet restore
dotnet build
dotnet run
```

Tạo database:

```powershell
dotnet ef migrations add InitialCreate
dotnet ef database update
```

Swagger chạy trong môi trường Development tại `/swagger`.
