using BookReader.Api.DTOs.Membership;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface IMembershipService
{
    Task<ApiResponse<List<MembershipPackageDto>>> GetActivePackagesAsync();
    Task<ApiResponse<UserMembershipDto>> SubscribeAsync(int userId, int packageId);
    Task<ApiResponse<UserMembershipDto>> GetMyPlanAsync(int userId);
}
