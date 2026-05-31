namespace BookReader.Api.DTOs.Progress;

public class SaveProgressRequest
{
    public int CurrentPage { get; set; }
    public decimal ProgressPercent { get; set; }
}

public class ProgressDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int BookId { get; set; }
    public int CurrentPage { get; set; }
    public decimal ProgressPercent { get; set; }
    public DateTime UpdatedAt { get; set; }
}
