using BookReader.Api.DTOs.Library;
using BookReader.Api.Entities;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Interfaces;

namespace BookReader.Api.Services.Implementations;

public class LibraryService : ILibraryService
{
    private readonly ILibraryRepository _libraryRepository;

    public LibraryService(ILibraryRepository libraryRepository)
    {
        _libraryRepository = libraryRepository;
    }

    public async Task<ApiResponse<List<LibraryItemDto>>> GetByUserAsync(int userId)
    {
        var items = await _libraryRepository.GetByUserAsync(userId);
        return ApiResponse<List<LibraryItemDto>>.Ok(items.Select(ToDto).ToList());
    }

    public async Task<ApiResponse<LibraryItemDto>> AddAsync(AddToLibraryRequest request)
    {
        var existing = await _libraryRepository.GetAsync(request.UserId, request.BookId);
        if (existing != null)
        {
            return ApiResponse<LibraryItemDto>.Ok(ToDto(existing), "Book already exists in library.");
        }

        var item = new UserLibrary
        {
            UserId = request.UserId,
            BookId = request.BookId,
            IsFavorite = false,
            IsDownloaded = false,
            AddedAt = DateTime.UtcNow
        };

        var created = await _libraryRepository.AddAsync(item);
        return ApiResponse<LibraryItemDto>.Ok(ToDto(created), "Added to library.");
    }

    public async Task<ApiResponse<bool>> RemoveAsync(int userId, int bookId)
    {
        var removed = await _libraryRepository.RemoveAsync(userId, bookId);
        return removed
            ? ApiResponse<bool>.Ok(true, "Removed from library.")
            : ApiResponse<bool>.Fail("Library item not found.");
    }

    private static LibraryItemDto ToDto(UserLibrary item)
    {
        return new LibraryItemDto
        {
            Id = item.Id,
            UserId = item.UserId,
            BookId = item.BookId,
            IsFavorite = item.IsFavorite,
            IsDownloaded = item.IsDownloaded,
            AddedAt = item.AddedAt,
            Book = item.Book == null ? null : BookService.ToDto(item.Book)
        };
    }
}
