using BookReader.Api.DTOs.Books;

namespace BookReader.Api.DTOs.Library;

public class AddToLibraryRequest
{
    public int UserId { get; set; }
    public int BookId { get; set; }
}

public class LibraryItemDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int BookId { get; set; }
    public bool IsFavorite { get; set; }
    public bool IsDownloaded { get; set; }
    public DateTime AddedAt { get; set; }
    public BookDto? Book { get; set; }
}
