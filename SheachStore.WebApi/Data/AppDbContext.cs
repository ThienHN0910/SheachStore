using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Data;

public class AppDbContext : IdentityDbContext<User, IdentityRole, string>
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public DbSet<Book> Books => Set<Book>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Author> Authors => Set<Author>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<Cart> Carts => Set<Cart>();
    public DbSet<CartItem> CartItems => Set<CartItem>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<WishlistItem> WishlistItems => Set<WishlistItem>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<User>(entity =>
        {
            entity.Property(user => user.FullName).HasMaxLength(150).IsRequired();
            entity.Property(user => user.Role).HasConversion<string>().HasMaxLength(30).IsRequired();
            entity.Property(user => user.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
        });

        builder.Entity<Author>(entity =>
        {
            entity.Property(author => author.Name).HasMaxLength(150).IsRequired();
            entity.Property(author => author.Bio).HasMaxLength(2000);

            entity.HasMany(author => author.Books)
                .WithOne(book => book.Author)
                .HasForeignKey(book => book.AuthorId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<Category>(entity =>
        {
            entity.Property(category => category.Name).HasMaxLength(120).IsRequired();
            entity.Property(category => category.Slug).HasMaxLength(150).IsRequired();
            entity.HasIndex(category => category.Slug).IsUnique();

            entity.HasMany(category => category.Books)
                .WithOne(book => book.Category)
                .HasForeignKey(book => book.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<Book>(entity =>
        {
            entity.Property(book => book.Title).HasMaxLength(250).IsRequired();
            entity.Property(book => book.Price).HasPrecision(18, 2);
            entity.Property(book => book.CoverUrl).HasMaxLength(500);
            entity.Property(book => book.Description).HasMaxLength(4000);
        });

        builder.Entity<Order>(entity =>
        {
            entity.Property(order => order.TotalAmount).HasPrecision(18, 2);
            entity.Property(order => order.Status).HasConversion<string>().HasMaxLength(30).IsRequired();
            entity.Property(order => order.PaymentMethod).HasMaxLength(30).IsRequired();
            entity.Property(order => order.ShippingAddress).HasMaxLength(500).IsRequired();
            entity.Property(order => order.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            entity.HasOne(order => order.User)
                .WithMany(user => user.Orders)
                .HasForeignKey(order => order.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasMany(order => order.OrderItems)
                .WithOne(item => item.Order)
                .HasForeignKey(item => item.OrderId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<OrderItem>(entity =>
        {
            entity.Property(item => item.UnitPrice).HasPrecision(18, 2);

            entity.HasOne(item => item.Book)
                .WithMany(book => book.OrderItems)
                .HasForeignKey(item => item.BookId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<Review>(entity =>
        {
            entity.ToTable(table => table.HasCheckConstraint("CK_Reviews_Rating", "[Rating] >= 1 AND [Rating] <= 5"));
            entity.Property(review => review.Comment).HasMaxLength(2000);
            entity.Property(review => review.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            entity.HasIndex(review => new { review.UserId, review.BookId }).IsUnique();

            entity.HasOne(review => review.User)
                .WithMany(user => user.Reviews)
                .HasForeignKey(review => review.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(review => review.Book)
                .WithMany(book => book.Reviews)
                .HasForeignKey(review => review.BookId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<Cart>(entity =>
        {
            entity.Property(cart => cart.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            entity.Property(cart => cart.UpdatedAt).HasDefaultValueSql("GETUTCDATE()");
            entity.HasIndex(cart => cart.UserId).IsUnique();

            entity.HasOne(cart => cart.User)
                .WithOne(user => user.Cart)
                .HasForeignKey<Cart>(cart => cart.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasMany(cart => cart.CartItems)
                .WithOne(item => item.Cart)
                .HasForeignKey(item => item.CartId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<CartItem>(entity =>
        {
            entity.Property(item => item.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            entity.HasIndex(item => new { item.CartId, item.BookId }).IsUnique();

            entity.HasOne(item => item.Book)
                .WithMany(book => book.CartItems)
                .HasForeignKey(item => item.BookId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<WishlistItem>(entity =>
        {
            entity.Property(item => item.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            entity.HasIndex(item => new { item.UserId, item.BookId }).IsUnique();

            entity.HasOne(item => item.User)
                .WithMany(user => user.WishlistItems)
                .HasForeignKey(item => item.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(item => item.Book)
                .WithMany(book => book.WishlistItems)
                .HasForeignKey(item => item.BookId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
