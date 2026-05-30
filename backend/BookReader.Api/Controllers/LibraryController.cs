using BookReader.Api.DTOs.Library;
using BookReader.Api.Helpers;
using BookReader.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BookReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LibraryController : ControllerBase
{
    private readonly ILibraryService _libraryService;
    private readonly JwtHelper _jwtHelper;

    public LibraryController(ILibraryService libraryService, JwtHelper jwtHelper)
    {
        _libraryService = libraryService;
        _jwtHelper = jwtHelper;
    }

    [HttpGet]
    public async Task<IActionResult> GetByUser([FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _libraryService.GetByUserAsync(resolvedUserId.Value);
        return Ok(result);
    }

    [HttpPost("{bookId:int}")]
    public async Task<IActionResult> Add(int bookId, [FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _libraryService.AddAsync(resolvedUserId.Value, bookId);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("{bookId:int}")]
    public async Task<IActionResult> Remove(int bookId, [FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _libraryService.RemoveAsync(resolvedUserId.Value, bookId);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [HttpPut("{bookId:int}/favorite")]
    public async Task<IActionResult> SetFavorite(int bookId, FavoriteRequest request, [FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _libraryService.SetFavoriteAsync(resolvedUserId.Value, bookId, request.IsFavorite);
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
