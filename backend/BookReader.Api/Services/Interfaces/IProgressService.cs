using BookReader.Api.DTOs.Progress;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface IProgressService
{
    Task<ApiResponse<ProgressDto>> GetAsync(int userId, int bookId);
    Task<ApiResponse<ProgressDto>> SaveAsync(SaveProgressRequest request);
}
