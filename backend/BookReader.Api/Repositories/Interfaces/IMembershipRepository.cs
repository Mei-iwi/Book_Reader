using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface IMembershipRepository
{
    Task<List<MembershipPackage>> GetActivePackagesAsync();
    Task<MembershipPackage?> GetPackageAsync(int packageId);
    Task<UserMembership?> GetCurrentPlanAsync(int userId);
    Task<UserMembership> SubscribeAsync(UserMembership membership);
}
