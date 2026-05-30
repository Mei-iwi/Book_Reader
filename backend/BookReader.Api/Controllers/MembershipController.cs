using BookReader.Api.Helpers;
using BookReader.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BookReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MembershipController : ControllerBase
{
    private readonly IMembershipService _membershipService;
    private readonly JwtHelper _jwtHelper;

    public MembershipController(IMembershipService membershipService, JwtHelper jwtHelper)
    {
        _membershipService = membershipService;
        _jwtHelper = jwtHelper;
    }

    [HttpGet("packages")]
    public async Task<IActionResult> GetPackages()
    {
        var result = await _membershipService.GetActivePackagesAsync();
        return Ok(result);
    }

    [HttpPost("subscribe/{packageId:int}")]
    public async Task<IActionResult> Subscribe(int packageId, [FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _membershipService.SubscribeAsync(resolvedUserId.Value, packageId);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [HttpGet("my-plan")]
    public async Task<IActionResult> MyPlan([FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _membershipService.GetMyPlanAsync(resolvedUserId.Value);
        return result.Success ? Ok(result) : NotFound(result);
    }

    private int? ResolveUserId(int? fallbackUserId)
    {
        var authorizationHeader = Request.Headers.Authorization.ToString();
        if (authorizationHeader.StartsWith("Bearer "))
        {
            return _jwtHelper.GetUserIdFromToken(authorizationHeader["Bearer ".Length..].Trim());
        }

        return fallbackUserId;
    }
}
