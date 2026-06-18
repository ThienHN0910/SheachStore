using Microsoft.EntityFrameworkCore;
using SheachStore.WebApi.Data;
using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Repositories;

public class CartRepository : Repository<Cart>, ICartRepository
{
    private readonly AppDbContext _dbContext;

    public CartRepository(AppDbContext dbContext)
        : base(dbContext)
    {
        _dbContext = dbContext;
    }

    public Task<Cart?> GetByUserIdAsync(string userId, CancellationToken cancellationToken = default)
    {
        return _dbContext.Carts
            .Include(cart => cart.CartItems)
            .ThenInclude(item => item.Book)
            .FirstOrDefaultAsync(cart => cart.UserId == userId, cancellationToken);
    }
}
