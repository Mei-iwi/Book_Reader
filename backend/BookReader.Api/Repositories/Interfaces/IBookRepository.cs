using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface IBookRepository
{
    Task<List<Book>> GetAllAsync(string? search);
    Task<Book?> GetByIdAsync(int id);
}
