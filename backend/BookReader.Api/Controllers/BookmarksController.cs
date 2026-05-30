using BookReader.Api.DTOs.Bookmarks;
using BookReader.Api.Helpers;
using BookReader.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BookReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BookmarksController : ControllerBase
{
    private readonly IBookmarkService _bookmarkService;
    private readonly JwtHelper _jwtHelper;

    public BookmarksController(IBookmarkService bookmarkService, JwtHelper jwtHelper)
    {
        _bookmarkService = bookmarkService;
        _jwtHelper = jwtHelper;
    }

    [HttpGet]
    public async Task<IActionResult> GetByBook([FromQuery] int bookId, [FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _bookmarkService.GetByBookAsync(resolvedUserId.Value, bookId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Add(SaveBookmarkRequest request, [FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _bookmarkService.AddAsync(resolvedUserId.Value, request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, UpdateBookmarkRequest request, [FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _bookmarkService.UpdateAsync(resolvedUserId.Value, id, request);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, [FromQuery] int? userId)
    {
        var resolvedUserId = ResolveUserId(userId);
        if (resolvedUserId == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<string>.Fail("Missing user id or bearer token."));
        }

        var result = await _bookmarkService.DeleteAsync(resolvedUserId.Value, id);
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
