namespace BookReader.Api.DTOs.Books;

public class BookDto
{
    public int Id { get; set; }
    public string? GoogleBookId { get; set; }
    public string Title { get; set; } = string.Empty;
    public List<string> Authors { get; set; } = new();
    public string? Description { get; set; }
    public string? ThumbnailUrl { get; set; }
    public List<string> Categories { get; set; } = new();
    public int PageCount { get; set; }
    public string? Language { get; set; }
    public string? PreviewLink { get; set; }
    public string? WebReaderLink { get; set; }
    public string Source { get; set; } = string.Empty;
    public string? PdfDownloadLink { get; set; }
    public string? EpubDownloadLink { get; set; }
}

public class SaveBookRequest
{
    public string? GoogleBookId { get; set; }
    public string Title { get; set; } = string.Empty;
    public List<string> Authors { get; set; } = new();
    public string? Description { get; set; }
    public string? ThumbnailUrl { get; set; }
    public List<string> Categories { get; set; } = new();
    public int PageCount { get; set; }
    public string? Language { get; set; }
    public string? PreviewLink { get; set; }
    public string? WebReaderLink { get; set; }
    public string? Source { get; set; }
    public string? PdfDownloadLink { get; set; }
    public string? EpubDownloadLink { get; set; }
}
