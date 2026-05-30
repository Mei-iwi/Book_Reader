using BookReader.Api.DTOs.Notes;
using BookReader.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BookReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class NotesController : ControllerBase
{
    private readonly INoteService _noteService;

    public NotesController(INoteService noteService)
    {
        _noteService = noteService;
    }

    [HttpGet("{userId:int}/{bookId:int}")]
    public async Task<IActionResult> GetByBook(int userId, int bookId)
    {
        var result = await _noteService.GetByBookAsync(userId, bookId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Add(SaveNoteRequest request)
    {
        var result = await _noteService.AddAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("{userId:int}/{noteId:int}")]
    public async Task<IActionResult> Delete(int userId, int noteId)
    {
        var result = await _noteService.DeleteAsync(userId, noteId);
        return result.Success ? Ok(result) : NotFound(result);
    }
}
