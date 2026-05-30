using BookReader.Api.DTOs.Library;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface ILibraryService
{
    Task<ApiResponse<List<LibraryItemDto>>> GetByUserAsync(int userId);
    Task<ApiResponse<LibraryItemDto>> AddAsync(AddToLibraryRequest request);
    Task<ApiResponse<bool>> RemoveAsync(int userId, int bookId);
}
