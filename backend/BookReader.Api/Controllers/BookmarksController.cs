using BookReader.Api.DTOs.Bookmarks;
using BookReader.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BookReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BookmarksController : ControllerBase
{
    private readonly IBookmarkService _bookmarkService;

    public BookmarksController(IBookmarkService bookmarkService)
    {
        _bookmarkService = bookmarkService;
    }

    [HttpGet("{userId:int}/{bookId:int}")]
    public async Task<IActionResult> GetByBook(int userId, int bookId)
    {
        var result = await _bookmarkService.GetByBookAsync(userId, bookId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Add(SaveBookmarkRequest request)
    {
        var result = await _bookmarkService.AddAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("{userId:int}/{bookmarkId:int}")]
    public async Task<IActionResult> Delete(int userId, int bookmarkId)
    {
        var result = await _bookmarkService.DeleteAsync(userId, bookmarkId);
        return result.Success ? Ok(result) : NotFound(result);
    }
}
