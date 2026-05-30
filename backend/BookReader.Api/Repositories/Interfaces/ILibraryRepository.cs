using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface ILibraryRepository
{
    Task<List<UserLibrary>> GetByUserAsync(int userId);
    Task<UserLibrary?> GetAsync(int userId, int bookId);
    Task<UserLibrary> AddAsync(UserLibrary item);
    Task<bool> RemoveAsync(int userId, int bookId);
    Task<UserLibrary?> SetFavoriteAsync(int userId, int bookId, bool isFavorite);
}
