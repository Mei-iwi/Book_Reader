using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface IBookRepository
{
    Task<List<Book>> GetPagedAsync(string? keyword, int page, int pageSize);
    Task<Book?> GetByIdAsync(int id);
    Task<Book?> GetByGoogleBookIdAsync(string googleBookId);
    Task<Book> CreateAsync(Book book, List<string> authors, List<string> categories);
    Task<Book?> UpdateAsync(int id, Book book, List<string> authors, List<string> categories);
    Task<bool> DeleteAsync(int id);
}
