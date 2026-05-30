using BookReader.Api.Data;
using BookReader.Api.Entities;
using BookReader.Api.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BookReader.Api.Repositories.Implementations;

public class BookRepository : IBookRepository
{
    private readonly BookReaderDbContext _context;

    public BookRepository(BookReaderDbContext context)
    {
        _context = context;
    }

    public async Task<List<Book>> GetAllAsync(string? search)
    {
        var query = _context.Books
            .Include(x => x.Authors)
            .Include(x => x.Categories)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(x => x.Title.Contains(search));
        }

        return await query.OrderBy(x => x.Title).ToListAsync();
    }

    public async Task<Book?> GetByIdAsync(int id)
    {
        return await _context.Books
            .Include(x => x.Authors)
            .Include(x => x.Categories)
            .FirstOrDefaultAsync(x => x.Id == id);
    }
}
