using BookReader.Api.Data;
using BookReader.Api.Entities;
using BookReader.Api.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BookReader.Api.Repositories.Implementations;

public class MembershipRepository : IMembershipRepository
{
    private readonly BookReaderDbContext _context;

    public MembershipRepository(BookReaderDbContext context)
    {
        _context = context;
    }

    public async Task<List<MembershipPackage>> GetActivePackagesAsync()
    {
        return await _context.MembershipPackages
            .Where(x => x.IsActive)
            .OrderBy(x => x.Price)
            .ToListAsync();
    }
}
