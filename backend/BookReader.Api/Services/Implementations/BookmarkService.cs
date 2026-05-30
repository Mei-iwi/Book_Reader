using BookReader.Api.DTOs.Bookmarks;
using BookReader.Api.Entities;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Interfaces;

namespace BookReader.Api.Services.Implementations;

public class BookmarkService : IBookmarkService
{
    private readonly IBookmarkRepository _bookmarkRepository;

    public BookmarkService(IBookmarkRepository bookmarkRepository)
    {
        _bookmarkRepository = bookmarkRepository;
    }

    public async Task<ApiResponse<List<BookmarkDto>>> GetByBookAsync(int userId, int bookId)
    {
        var bookmarks = await _bookmarkRepository.GetByBookAsync(userId, bookId);
        return ApiResponse<List<BookmarkDto>>.Ok(bookmarks.Select(ToDto).ToList());
    }

    public async Task<ApiResponse<BookmarkDto>> AddAsync(int userId, SaveBookmarkRequest request)
    {
        var bookmark = new Bookmark
        {
            UserId = userId,
            BookId = request.BookId,
            Page = request.Page,
            Note = request.Note,
            CreatedAt = DateTime.UtcNow
        };

        var created = await _bookmarkRepository.AddAsync(bookmark);
        return ApiResponse<BookmarkDto>.Ok(ToDto(created), "Bookmark saved.");
    }

    public async Task<ApiResponse<BookmarkDto>> UpdateAsync(int userId, int bookmarkId, UpdateBookmarkRequest request)
    {
        var bookmark = await _bookmarkRepository.UpdateAsync(userId, bookmarkId, request.Page, request.Note);
        return bookmark == null
            ? ApiResponse<BookmarkDto>.Fail("Bookmark not found.")
            : ApiResponse<BookmarkDto>.Ok(ToDto(bookmark), "Bookmark updated.");
    }

    public async Task<ApiResponse<bool>> DeleteAsync(int userId, int bookmarkId)
    {
        var deleted = await _bookmarkRepository.DeleteAsync(userId, bookmarkId);
        return deleted
            ? ApiResponse<bool>.Ok(true, "Bookmark deleted.")
            : ApiResponse<bool>.Fail("Bookmark not found.");
    }

    private static BookmarkDto ToDto(Bookmark bookmark)
    {
        return new BookmarkDto
        {
            Id = bookmark.Id,
            UserId = bookmark.UserId,
            BookId = bookmark.BookId,
            Page = bookmark.Page,
            Note = bookmark.Note,
            CreatedAt = bookmark.CreatedAt,
            UpdatedAt = bookmark.UpdatedAt
        };
    }
}
