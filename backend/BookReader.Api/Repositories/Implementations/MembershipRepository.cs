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

    public async Task<MembershipPackage?> GetPackageAsync(int packageId)
    {
        return await _context.MembershipPackages.FirstOrDefaultAsync(x => x.Id == packageId && x.IsActive);
    }

    public async Task<UserMembership?> GetCurrentPlanAsync(int userId)
    {
        return await _context.UserMemberships
            .Include(x => x.MembershipPackage)
            .Where(x => x.UserId == userId && x.Status == "Active")
            .OrderByDescending(x => x.EndDate)
            .FirstOrDefaultAsync();
    }

    public async Task<UserMembership> SubscribeAsync(UserMembership membership)
    {
        var currentPlans = await _context.UserMemberships
            .Where(x => x.UserId == membership.UserId && x.Status == "Active")
            .ToListAsync();

        foreach (var plan in currentPlans)
        {
            plan.Status = "Expired";
        }

        _context.UserMemberships.Add(membership);
        await _context.SaveChangesAsync();
        await _context.Entry(membership).Reference(x => x.MembershipPackage).LoadAsync();
        return membership;
    }
}
