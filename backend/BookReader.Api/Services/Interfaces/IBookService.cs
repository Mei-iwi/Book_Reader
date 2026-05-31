using BookReader.Api.DTOs.Books;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface IBookService
{
    Task<ApiResponse<List<BookDto>>> GetPagedAsync(string? keyword, int page, int pageSize);
    Task<ApiResponse<BookDto>> GetByIdAsync(int id);
    Task<ApiResponse<BookDto>> CreateAsync(SaveBookRequest request);
    Task<ApiResponse<BookDto>> UpdateAsync(int id, SaveBookRequest request);
    Task<ApiResponse<bool>> DeleteAsync(int id);
    Task<ApiResponse<BookDto>> ImportGoogleBookAsync(string googleBookId);
}
