using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface IBookmarkRepository
{
    Task<List<Bookmark>> GetByBookAsync(int userId, int bookId);
    Task<Bookmark> AddAsync(Bookmark bookmark);
    Task<Bookmark?> UpdateAsync(int userId, int bookmarkId, int page, string? note);
    Task<bool> DeleteAsync(int userId, int bookmarkId);
}
