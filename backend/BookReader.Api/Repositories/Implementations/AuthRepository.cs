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
        return await _context.AppUsers.FirstOrDefaultAsync(x => x.Email == email);
    }

    public async Task<AppUser> CreateAsync(AppUser user)
    {
        _context.AppUsers.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }
}
