using Microsoft.EntityFrameworkCore;
using SheachStore.WebApi.Data;
using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Repositories;

public class OrderRepository : Repository<Order>, IOrderRepository
{
    private readonly AppDbContext _dbContext;

    public OrderRepository(AppDbContext dbContext)
        : base(dbContext)
    {
        _dbContext = dbContext;
    }

    public Task<List<Order>> GetAllWithDetailsAsync(CancellationToken cancellationToken = default)
    {
        return QueryWithDetails()
            .AsNoTracking()
            .OrderByDescending(order => order.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public Task<List<Order>> GetByUserIdAsync(string userId, CancellationToken cancellationToken = default)
    {
        return QueryWithDetails()
            .AsNoTracking()
            .Where(order => order.UserId == userId)
            .OrderByDescending(order => order.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public Task<Order?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default)
    {
        return QueryWithDetails().FirstOrDefaultAsync(order => order.Id == id, cancellationToken);
    }

    private IQueryable<Order> QueryWithDetails()
    {
        return _dbContext.Orders
            .Include(order => order.OrderItems)
            .ThenInclude(item => item.Book);
    }
}
