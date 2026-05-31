namespace BookReader.Api.DTOs.Bookmarks;

public class SaveBookmarkRequest
{
    public int BookId { get; set; }
    public int Page { get; set; }
    public string? Note { get; set; }
}

public class UpdateBookmarkRequest
{
    public int Page { get; set; }
    public string? Note { get; set; }
}

public class BookmarkDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int BookId { get; set; }
    public int Page { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
