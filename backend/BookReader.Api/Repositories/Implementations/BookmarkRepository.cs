using BookReader.Api.Data;
using BookReader.Api.Entities;
using BookReader.Api.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BookReader.Api.Repositories.Implementations;

public class BookmarkRepository : IBookmarkRepository
{
    private readonly BookReaderDbContext _context;

    public BookmarkRepository(BookReaderDbContext context)
    {
        _context = context;
    }

    public async Task<List<Bookmark>> GetByBookAsync(int userId, int bookId)
    {
        return await _context.Bookmarks
            .Where(x => x.UserId == userId && x.BookId == bookId)
            .OrderBy(x => x.Page)
            .ToListAsync();
    }

    public async Task<Bookmark> AddAsync(Bookmark bookmark)
    {
        _context.Bookmarks.Add(bookmark);
        await _context.SaveChangesAsync();
        return bookmark;
    }

    public async Task<bool> DeleteAsync(int userId, int bookmarkId)
    {
        var bookmark = await _context.Bookmarks.FirstOrDefaultAsync(x => x.UserId == userId && x.Id == bookmarkId);
        if (bookmark == null)
        {
            return false;
        }

        _context.Bookmarks.Remove(bookmark);
        await _context.SaveChangesAsync();
        return true;
    }
}
