using Microsoft.EntityFrameworkCore;
using SheachStore.WebApi.Data;
using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Repositories;

public class BookRepository : Repository<Book>, IBookRepository
{
    private readonly AppDbContext _dbContext;

    public BookRepository(AppDbContext dbContext)
        : base(dbContext)
    {
        _dbContext = dbContext;
    }

    public Task<List<Book>> GetAllWithDetailsAsync(CancellationToken cancellationToken = default)
    {
        return _dbContext.Books
            .AsNoTracking()
            .Include(book => book.Author)
            .Include(book => book.Category)
            .ToListAsync(cancellationToken);
    }

    public Task<Book?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default)
    {
        return _dbContext.Books
            .AsNoTracking()
            .Include(book => book.Author)
            .Include(book => book.Category)
            .FirstOrDefaultAsync(book => book.Id == id, cancellationToken);
    }
}
