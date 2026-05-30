using BookReader.Api.DTOs.Books;
using BookReader.Api.Entities;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Interfaces;

namespace BookReader.Api.Services.Implementations;

public class BookService : IBookService
{
    private readonly IBookRepository _bookRepository;
    private readonly IGoogleBooksService _googleBooksService;

    public BookService(IBookRepository bookRepository, IGoogleBooksService googleBooksService)
    {
        _bookRepository = bookRepository;
        _googleBooksService = googleBooksService;
    }

    public async Task<ApiResponse<List<BookDto>>> GetPagedAsync(string? keyword, int page, int pageSize)
    {
        page = page < 1 ? 1 : page;
        pageSize = pageSize < 1 ? 10 : pageSize;
        var books = await _bookRepository.GetPagedAsync(keyword, page, pageSize);
        return ApiResponse<List<BookDto>>.Ok(books.Select(ToDto).ToList());
    }

    public async Task<ApiResponse<BookDto>> GetByIdAsync(int id)
    {
        var book = await _bookRepository.GetByIdAsync(id);
        return book == null
            ? ApiResponse<BookDto>.Fail("Book not found.")
            : ApiResponse<BookDto>.Ok(ToDto(book));
    }

    public async Task<ApiResponse<BookDto>> CreateAsync(SaveBookRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Title))
        {
            return ApiResponse<BookDto>.Fail("Title is required.");
        }

        var book = ToEntity(request);
        book.CreatedAt = DateTime.UtcNow;
        var created = await _bookRepository.CreateAsync(book, request.Authors, request.Categories);
        return ApiResponse<BookDto>.Ok(ToDto(created), "Book created.");
    }

    public async Task<ApiResponse<BookDto>> UpdateAsync(int id, SaveBookRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Title))
        {
            return ApiResponse<BookDto>.Fail("Title is required.");
        }

        var updated = await _bookRepository.UpdateAsync(id, ToEntity(request), request.Authors, request.Categories);
        return updated == null
            ? ApiResponse<BookDto>.Fail("Book not found.")
            : ApiResponse<BookDto>.Ok(ToDto(updated), "Book updated.");
    }

    public async Task<ApiResponse<bool>> DeleteAsync(int id)
    {
        var deleted = await _bookRepository.DeleteAsync(id);
        return deleted
            ? ApiResponse<bool>.Ok(true, "Book deleted.")
            : ApiResponse<bool>.Fail("Book not found.");
    }

    public async Task<ApiResponse<BookDto>> ImportGoogleBookAsync(string googleBookId)
    {
        var existing = await _bookRepository.GetByGoogleBookIdAsync(googleBookId);
        if (existing != null)
        {
            return ApiResponse<BookDto>.Ok(ToDto(existing), "Book already exists.");
        }

        var googleBook = await _googleBooksService.GetByIdAsync(googleBookId);
        if (!googleBook.Success || googleBook.Data == null)
        {
            return ApiResponse<BookDto>.Fail(googleBook.Message);
        }

        var request = new SaveBookRequest
        {
            GoogleBookId = googleBook.Data.GoogleBookId,
            Title = googleBook.Data.Title,
            Authors = googleBook.Data.Authors,
            Description = googleBook.Data.Description,
            ThumbnailUrl = googleBook.Data.ThumbnailUrl,
            Categories = googleBook.Data.Categories,
            PageCount = googleBook.Data.PageCount,
            Language = googleBook.Data.Language,
            PreviewLink = googleBook.Data.PreviewLink,
            WebReaderLink = googleBook.Data.WebReaderLink,
            Source = "google_books",
            PdfDownloadLink = googleBook.Data.PdfDownloadLink,
            EpubDownloadLink = googleBook.Data.EpubDownloadLink
        };

        return await CreateAsync(request);
    }

    public static BookDto ToDto(Book book)
    {
        return new BookDto
        {
            Id = book.Id,
            GoogleBookId = book.GoogleBookId,
            Title = book.Title,
            Description = book.Description,
            ThumbnailUrl = book.ThumbnailUrl,
            Categories = book.Categories.Select(x => x.Name).ToList(),
            PageCount = book.PageCount,
            Language = book.Language,
            PreviewLink = book.PreviewLink,
            WebReaderLink = book.WebReaderLink,
            Source = book.Source,
            PdfDownloadLink = book.PdfDownloadLink,
            EpubDownloadLink = book.EpubDownloadLink,
            Authors = book.Authors.Select(x => x.Name).ToList()
        };
    }

    private static Book ToEntity(SaveBookRequest request)
    {
        return new Book
        {
            GoogleBookId = request.GoogleBookId,
            Title = request.Title.Trim(),
            Description = request.Description,
            ThumbnailUrl = request.ThumbnailUrl,
            PageCount = request.PageCount,
            Language = request.Language,
            PreviewLink = request.PreviewLink,
            WebReaderLink = request.WebReaderLink,
            Source = string.IsNullOrWhiteSpace(request.Source) ? "local" : request.Source,
            PdfDownloadLink = request.PdfDownloadLink,
            EpubDownloadLink = request.EpubDownloadLink
        };
    }
}
