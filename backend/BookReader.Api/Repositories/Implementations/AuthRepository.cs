using BookReader.Api.Data;
using BookReader.Api.Entities;
using BookReader.Api.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BookReader.Api.Repositories.Implementations;

public class AuthRepository : IAuthRepository
{
    private readonly BookReaderDbContext _context;

    public AuthRepository(BookReaderDbContext context)
    {
        _context = context;
    }

    public async Task<AppUser?> GetByIdAsync(int id)
    {
        return await _context.AppUsers.FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task<AppUser?> GetByEmailAsync(string email)
    {
        return await _context.AppUsers
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Email == email);
    }

    public async Task<List<AppUser>> GetAllAsync()
    {
        return await _context.AppUsers
            .AsNoTracking()
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();
    }

    public async Task<AppUser> CreateAsync(AppUser user)
    {
        _context.AppUsers.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }

    public async Task<AppUser> UpdateAsync(AppUser user)
    {
        _context.AppUsers.Update(user);
        await _context.SaveChangesAsync();
        return user;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var user = await GetByIdAsync(id);
        if (user == null)
        {
            return false;
        }

        _context.Bookmarks.RemoveRange(_context.Bookmarks.Where(x => x.UserId == id));
        _context.NoteHighlights.RemoveRange(_context.NoteHighlights.Where(x => x.UserId == id));
        _context.ReadingProgresses.RemoveRange(_context.ReadingProgresses.Where(x => x.UserId == id));
        _context.Reviews.RemoveRange(_context.Reviews.Where(x => x.UserId == id));
        _context.UserLibraries.RemoveRange(_context.UserLibraries.Where(x => x.UserId == id));
        _context.UserMemberships.RemoveRange(_context.UserMemberships.Where(x => x.UserId == id));
        _context.AppUsers.Remove(user);
        await _context.SaveChangesAsync();
        return true;
    }
}
