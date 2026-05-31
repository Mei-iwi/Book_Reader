using BookReader.Api.DTOs.Books;
using BookReader.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BookReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly IBookService _bookService;
    private readonly IGoogleBooksService _googleBooksService;

    public BooksController(IBookService bookService, IGoogleBooksService googleBooksService)
    {
        _bookService = bookService;
        _googleBooksService = googleBooksService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? keyword, [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var result = await _bookService.GetPagedAsync(keyword, page, pageSize);
        return Ok(result);
    }

    [HttpGet("google/search")]
    public async Task<IActionResult> SearchGoogle([FromQuery] string keyword, [FromQuery] int startIndex = 0, [FromQuery] int maxResults = 10, [FromQuery] string? langRestrict = null, [FromQuery] bool onlyFreeEbooks = false)
    {
        var result = await _googleBooksService.SearchAsync(keyword, startIndex, maxResults, langRestrict, onlyFreeEbooks);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpGet("google/{googleBookId}")]
    public async Task<IActionResult> GetGoogleBook(string googleBookId)
    {
        var result = await _googleBooksService.GetByIdAsync(googleBookId);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [HttpPost("import-google/{googleBookId}")]
    public async Task<IActionResult> ImportGoogleBook(string googleBookId)
    {
        var result = await _bookService.ImportGoogleBookAsync(googleBookId);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _bookService.GetByIdAsync(id);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create(SaveBookRequest request)
    {
        var result = await _bookService.CreateAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, SaveBookRequest request)
    {
        var result = await _bookService.UpdateAsync(id, request);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _bookService.DeleteAsync(id);
        return result.Success ? Ok(result) : NotFound(result);
    }
}
