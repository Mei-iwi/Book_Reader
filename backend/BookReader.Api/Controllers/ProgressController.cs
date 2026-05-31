using BookReader.Api.DTOs.Progress;
using BookReader.Api.Helpers;
using BookReader.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BookReader.Api.Controllers;

[ApiController]
[Route("api/reading-progress")]
public class ProgressController : ControllerBase
{
    private readonly IProgressService _progressService;
    private readonly JwtHelper _jwtHelper;

    public ProgressController(IProgressService progressService, JwtHelper jwtHelper)
    {
        _progressService = progressService;
        _jwtHelper = jwtHelper;
    }

    [HttpGet("{bookId:int}")]
    public async Task<IActionResult> Get(int bookId, [FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _progressService.GetAsync(resolvedUserId.Value, bookId);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [HttpPut("{bookId:int}")]
    public async Task<IActionResult> Save(int bookId, SaveProgressRequest request, [FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _progressService.SaveAsync(resolvedUserId.Value, bookId, request);
        return result.Success ? Ok(result) : BadRequest(result);
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
