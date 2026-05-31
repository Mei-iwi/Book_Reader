using BookReader.Api.DTOs.Membership;
using BookReader.Api.Entities;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Interfaces;

namespace BookReader.Api.Services.Implementations;

public class MembershipService : IMembershipService
{
    private readonly IMembershipRepository _membershipRepository;

    public MembershipService(IMembershipRepository membershipRepository)
    {
        _membershipRepository = membershipRepository;
    }

    public async Task<ApiResponse<List<MembershipPackageDto>>> GetActivePackagesAsync()
    {
        var packages = await _membershipRepository.GetActivePackagesAsync();
        return ApiResponse<List<MembershipPackageDto>>.Ok(packages.Select(ToDto).ToList());
    }

    public async Task<ApiResponse<UserMembershipDto>> SubscribeAsync(int userId, int packageId)
    {
        var package = await _membershipRepository.GetPackageAsync(packageId);
        if (package == null)
        {
            return ApiResponse<UserMembershipDto>.Fail("Membership package not found.");
        }

        var startDate = DateTime.UtcNow;
        var membership = new UserMembership
        {
            UserId = userId,
            MembershipPackageId = package.Id,
            StartDate = startDate,
            EndDate = startDate.AddDays(package.DurationDays),
            Status = "Active"
        };

        var created = await _membershipRepository.SubscribeAsync(membership);
        return ApiResponse<UserMembershipDto>.Ok(ToDto(created), "Subscribed successfully.");
    }

    public async Task<ApiResponse<UserMembershipDto>> GetMyPlanAsync(int userId)
    {
        var plan = await _membershipRepository.GetCurrentPlanAsync(userId);
        return plan == null
            ? ApiResponse<UserMembershipDto>.Fail("No active membership plan.")
            : ApiResponse<UserMembershipDto>.Ok(ToDto(plan));
    }

    private static MembershipPackageDto ToDto(MembershipPackage package)
    {
        return new MembershipPackageDto
        {
            Id = package.Id,
            Name = package.Name,
            Price = package.Price,
            DurationDays = package.DurationDays,
            Description = package.Description,
            IsActive = package.IsActive
        };
    }

    private static UserMembershipDto ToDto(UserMembership membership)
    {
        return new UserMembershipDto
        {
            Id = membership.Id,
            UserId = membership.UserId,
            MembershipPackageId = membership.MembershipPackageId,
            PackageName = membership.MembershipPackage.Name,
            StartDate = membership.StartDate,
            EndDate = membership.EndDate,
            Status = membership.Status
        };
    }
}
