using BookReader.Api.DTOs.Progress;
using BookReader.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BookReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProgressController : ControllerBase
{
    private readonly IProgressService _progressService;

    public ProgressController(IProgressService progressService)
    {
        _progressService = progressService;
    }

    [HttpGet("{userId:int}/{bookId:int}")]
    public async Task<IActionResult> Get(int userId, int bookId)
    {
        var result = await _progressService.GetAsync(userId, bookId);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [HttpPost]
    public async Task<IActionResult> Save(SaveProgressRequest request)
    {
        var result = await _progressService.SaveAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}
