namespace BookReader.Api.DTOs.Notes;

public class SaveNoteRequest
{
    public int BookId { get; set; }
    public int Page { get; set; }
    public string? SelectedText { get; set; }
    public string? NoteContent { get; set; }
    public string? Color { get; set; }
}

public class UpdateNoteRequest
{
    public int Page { get; set; }
    public string? SelectedText { get; set; }
    public string? NoteContent { get; set; }
    public string? Color { get; set; }
}

public class NoteDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int BookId { get; set; }
    public int Page { get; set; }
    public string? SelectedText { get; set; }
    public string? NoteContent { get; set; }
    public string? Color { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
