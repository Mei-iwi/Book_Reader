using BookReader.Api.DTOs.Library;
using BookReader.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BookReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LibraryController : ControllerBase
{
    private readonly ILibraryService _libraryService;

    public LibraryController(ILibraryService libraryService)
    {
        _libraryService = libraryService;
    }

    [HttpGet("{userId:int}")]
    public async Task<IActionResult> GetByUser(int userId)
    {
        var result = await _libraryService.GetByUserAsync(userId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Add(AddToLibraryRequest request)
    {
        var result = await _libraryService.AddAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("{userId:int}/{bookId:int}")]
    public async Task<IActionResult> Remove(int userId, int bookId)
    {
        var result = await _libraryService.RemoveAsync(userId, bookId);
        return result.Success ? Ok(result) : NotFound(result);
    }
}
