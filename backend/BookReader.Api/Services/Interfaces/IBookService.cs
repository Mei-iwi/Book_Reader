using BookReader.Api.DTOs.Books;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface IBookService
{
    Task<ApiResponse<List<BookDto>>> GetAllAsync(string? search);
    Task<ApiResponse<BookDto>> GetByIdAsync(int id);
}
