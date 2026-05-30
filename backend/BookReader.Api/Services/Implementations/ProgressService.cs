using BookReader.Api.DTOs.Progress;
using BookReader.Api.Entities;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Interfaces;

namespace BookReader.Api.Services.Implementations;

public class ProgressService : IProgressService
{
    private readonly IProgressRepository _progressRepository;

    public ProgressService(IProgressRepository progressRepository)
    {
        _progressRepository = progressRepository;
    }

    public async Task<ApiResponse<ProgressDto>> GetAsync(int userId, int bookId)
    {
        var progress = await _progressRepository.GetAsync(userId, bookId);
        return progress == null
            ? ApiResponse<ProgressDto>.Fail("Progress not found.")
            : ApiResponse<ProgressDto>.Ok(ToDto(progress));
    }

    public async Task<ApiResponse<ProgressDto>> SaveAsync(SaveProgressRequest request)
    {
        var progress = new ReadingProgress
        {
            UserId = request.UserId,
            BookId = request.BookId,
            CurrentPage = request.CurrentPage,
            ProgressPercent = request.ProgressPercent,
            UpdatedAt = DateTime.UtcNow
        };

        var saved = await _progressRepository.SaveAsync(progress);
        return ApiResponse<ProgressDto>.Ok(ToDto(saved), "Progress saved.");
    }

    private static ProgressDto ToDto(ReadingProgress progress)
    {
        return new ProgressDto
        {
            Id = progress.Id,
            UserId = progress.UserId,
            BookId = progress.BookId,
            CurrentPage = progress.CurrentPage,
            ProgressPercent = progress.ProgressPercent,
            UpdatedAt = progress.UpdatedAt
        };
    }
}
