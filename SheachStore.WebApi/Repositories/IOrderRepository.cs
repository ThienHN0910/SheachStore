using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Repositories;

public interface IOrderRepository : IRepository<Order>
{
    Task<List<Order>> GetAllWithDetailsAsync(CancellationToken cancellationToken = default);
    Task<List<Order>> GetByUserIdAsync(string userId, CancellationToken cancellationToken = default);
    Task<Order?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default);
}
