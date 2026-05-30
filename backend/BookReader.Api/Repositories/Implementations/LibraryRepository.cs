using BookReader.Api.Data;
using BookReader.Api.Entities;
using BookReader.Api.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BookReader.Api.Repositories.Implementations;

public class LibraryRepository : ILibraryRepository
{
    private readonly BookReaderDbContext _context;

    public LibraryRepository(BookReaderDbContext context)
    {
        _context = context;
    }

    public async Task<List<UserLibrary>> GetByUserAsync(int userId)
    {
        return await _context.UserLibraries
            .Include(x => x.Book)
            .ThenInclude(x => x.Authors)
            .Include(x => x.Book)
            .ThenInclude(x => x.Categories)
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.AddedAt)
            .ToListAsync();
    }

    public async Task<UserLibrary?> GetAsync(int userId, int bookId)
    {
        return await _context.UserLibraries.FirstOrDefaultAsync(x => x.UserId == userId && x.BookId == bookId);
    }

    public async Task<UserLibrary> AddAsync(UserLibrary item)
    {
        _context.UserLibraries.Add(item);
        await _context.SaveChangesAsync();
        return item;
    }

    public async Task<bool> RemoveAsync(int userId, int bookId)
    {
        var item = await GetAsync(userId, bookId);
        if (item == null)
        {
            return false;
        }

        _context.UserLibraries.Remove(item);
        await _context.SaveChangesAsync();
        return true;
    }
}
