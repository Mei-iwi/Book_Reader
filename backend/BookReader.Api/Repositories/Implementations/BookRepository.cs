using BookReader.Api.Data;
using BookReader.Api.Entities;
using BookReader.Api.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BookReader.Api.Repositories.Implementations;

public class BookRepository : IBookRepository
{
    private readonly BookReaderDbContext _context;

    public BookRepository(BookReaderDbContext context)
    {
        _context = context;
    }

    public async Task<List<Book>> GetPagedAsync(string? keyword, int page, int pageSize)
    {
        var query = _context.Books
            .Include(x => x.Authors)
            .Include(x => x.Categories)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            query = query.Where(x =>
                x.Title.Contains(keyword) ||
                x.Authors.Any(a => a.Name.Contains(keyword)) ||
                x.Categories.Any(c => c.Name.Contains(keyword)));
        }

        return await query
            .OrderBy(x => x.Title)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task<Book?> GetByIdAsync(int id)
    {
        return await _context.Books
            .Include(x => x.Authors)
            .Include(x => x.Categories)
            .FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task<Book?> GetByGoogleBookIdAsync(string googleBookId)
    {
        return await _context.Books
            .Include(x => x.Authors)
            .Include(x => x.Categories)
            .FirstOrDefaultAsync(x => x.GoogleBookId == googleBookId);
    }

    public async Task<Book> CreateAsync(Book book, List<string> authors, List<string> categories)
    {
        await SetAuthorsAndCategoriesAsync(book, authors, categories);
        _context.Books.Add(book);
        await _context.SaveChangesAsync();
        return book;
    }

    public async Task<Book?> UpdateAsync(int id, Book book, List<string> authors, List<string> categories)
    {
        var existing = await _context.Books
            .Include(x => x.Authors)
            .Include(x => x.Categories)
            .FirstOrDefaultAsync(x => x.Id == id);

        if (existing == null)
        {
            return null;
        }

        existing.GoogleBookId = book.GoogleBookId;
        existing.Title = book.Title;
        existing.Description = book.Description;
        existing.ThumbnailUrl = book.ThumbnailUrl;
        existing.PageCount = book.PageCount;
        existing.Language = book.Language;
        existing.PreviewLink = book.PreviewLink;
        existing.WebReaderLink = book.WebReaderLink;
        existing.Source = book.Source;
        existing.PdfDownloadLink = book.PdfDownloadLink;
        existing.EpubDownloadLink = book.EpubDownloadLink;
        existing.UpdatedAt = DateTime.UtcNow;

        existing.Authors.Clear();
        existing.Categories.Clear();
        await SetAuthorsAndCategoriesAsync(existing, authors, categories);

        await _context.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var book = await _context.Books.FirstOrDefaultAsync(x => x.Id == id);
        if (book == null)
        {
            return false;
        }

        _context.Books.Remove(book);
        await _context.SaveChangesAsync();
        return true;
    }

    private async Task SetAuthorsAndCategoriesAsync(Book book, List<string> authorNames, List<string> categoryNames)
    {
        foreach (var name in authorNames.Select(x => x.Trim()).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct())
        {
            var author = await _context.Authors.FirstOrDefaultAsync(x => x.Name == name);
            book.Authors.Add(author ?? new Author { Name = name });
        }

        foreach (var name in categoryNames.Select(x => x.Trim()).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct())
        {
            var category = await _context.Categories.FirstOrDefaultAsync(x => x.Name == name);
            book.Categories.Add(category ?? new Category { Name = name });
        }
    }
}
