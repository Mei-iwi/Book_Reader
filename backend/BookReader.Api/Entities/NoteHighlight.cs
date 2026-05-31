using System;
using System.Collections.Generic;

namespace BookReader.Api.Entities;

public partial class NoteHighlight
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

    public virtual Book Book { get; set; } = null!;

    public virtual AppUser User { get; set; } = null!;
}
