using BookReader.Api.DTOs.Bookmarks;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface IBookmarkService
{
    Task<ApiResponse<List<BookmarkDto>>> GetByBookAsync(int userId, int bookId);
    Task<ApiResponse<BookmarkDto>> AddAsync(SaveBookmarkRequest request);
    Task<ApiResponse<bool>> DeleteAsync(int userId, int bookmarkId);
}
