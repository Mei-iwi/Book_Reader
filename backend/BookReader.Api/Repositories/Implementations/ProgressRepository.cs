using BookReader.Api.Data;
using BookReader.Api.Entities;
using BookReader.Api.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BookReader.Api.Repositories.Implementations;

public class ProgressRepository : IProgressRepository
{
    private readonly BookReaderDbContext _context;

    public ProgressRepository(BookReaderDbContext context)
    {
        _context = context;
    }

    public async Task<ReadingProgress?> GetAsync(int userId, int bookId)
    {
        return await _context.ReadingProgresses.FirstOrDefaultAsync(x => x.UserId == userId && x.BookId == bookId);
    }

    public async Task<ReadingProgress> SaveAsync(ReadingProgress progress)
    {
        var existing = await GetAsync(progress.UserId, progress.BookId);
        if (existing == null)
        {
            _context.ReadingProgresses.Add(progress);
            await _context.SaveChangesAsync();
            return progress;
        }

        existing.CurrentPage = progress.CurrentPage;
        existing.ProgressPercent = progress.ProgressPercent;
        existing.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return existing;
    }
}
