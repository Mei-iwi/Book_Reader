using BookReader.Api.DTOs.Library;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface ILibraryService
{
    Task<ApiResponse<List<LibraryItemDto>>> GetByUserAsync(int userId);
    Task<ApiResponse<LibraryItemDto>> AddAsync(int userId, int bookId);
    Task<ApiResponse<bool>> RemoveAsync(int userId, int bookId);
    Task<ApiResponse<LibraryItemDto>> SetFavoriteAsync(int userId, int bookId, bool isFavorite);
}
