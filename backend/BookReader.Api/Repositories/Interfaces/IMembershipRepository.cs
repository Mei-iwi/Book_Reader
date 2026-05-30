using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface IMembershipRepository
{
    Task<List<MembershipPackage>> GetActivePackagesAsync();
}
