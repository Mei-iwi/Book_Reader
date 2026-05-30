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
}
