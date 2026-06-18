using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Repositories;

public interface ICartRepository : IRepository<Cart>
{
    Task<Cart?> GetByUserIdAsync(string userId, CancellationToken cancellationToken = default);
}
