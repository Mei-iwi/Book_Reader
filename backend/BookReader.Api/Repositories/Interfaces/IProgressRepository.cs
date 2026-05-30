using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface IProgressRepository
{
    Task<ReadingProgress?> GetAsync(int userId, int bookId);
    Task<ReadingProgress> SaveAsync(ReadingProgress progress);
}
