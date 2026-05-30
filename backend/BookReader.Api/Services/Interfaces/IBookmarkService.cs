using BookReader.Api.DTOs.Bookmarks;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface IBookmarkService
{
    Task<ApiResponse<List<BookmarkDto>>> GetByBookAsync(int userId, int bookId);
    Task<ApiResponse<BookmarkDto>> AddAsync(int userId, SaveBookmarkRequest request);
    Task<ApiResponse<BookmarkDto>> UpdateAsync(int userId, int bookmarkId, UpdateBookmarkRequest request);
    Task<ApiResponse<bool>> DeleteAsync(int userId, int bookmarkId);
}
