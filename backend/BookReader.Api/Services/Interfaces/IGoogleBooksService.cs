using BookReader.Api.DTOs.Books;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface IGoogleBooksService
{
    Task<ApiResponse<List<BookDto>>> SearchAsync(string keyword, int startIndex, int maxResults, string? langRestrict, bool onlyFreeEbooks);
    Task<ApiResponse<BookDto>> GetByIdAsync(string googleBookId);
}
