using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Repositories;

public interface IBookRepository : IRepository<Book>
{
    Task<List<Book>> GetAllWithDetailsAsync(CancellationToken cancellationToken = default);
    Task<Book?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default);
}
