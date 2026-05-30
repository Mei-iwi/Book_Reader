using BookReader.Api.DTOs.Books;
using BookReader.Api.Entities;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Interfaces;

namespace BookReader.Api.Services.Implementations;

public class BookService : IBookService
{
    private readonly IBookRepository _bookRepository;

    public BookService(IBookRepository bookRepository)
    {
        _bookRepository = bookRepository;
    }

    public async Task<ApiResponse<List<BookDto>>> GetAllAsync(string? search)
    {
        var books = await _bookRepository.GetAllAsync(search);
        return ApiResponse<List<BookDto>>.Ok(books.Select(ToDto).ToList());
    }

    public async Task<ApiResponse<BookDto>> GetByIdAsync(int id)
    {
        var book = await _bookRepository.GetByIdAsync(id);
        return book == null
            ? ApiResponse<BookDto>.Fail("Book not found.")
            : ApiResponse<BookDto>.Ok(ToDto(book));
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
            CoverLocalPath = book.CoverLocalPath,
            PageCount = book.PageCount,
            Language = book.Language,
            PreviewLink = book.PreviewLink,
            WebReaderLink = book.WebReaderLink,
            PdfDownloadLink = book.PdfDownloadLink,
            EpubDownloadLink = book.EpubDownloadLink,
            Authors = book.Authors.Select(x => x.Name).ToList(),
            Categories = book.Categories.Select(x => x.Name).ToList()
        };
    }
}
