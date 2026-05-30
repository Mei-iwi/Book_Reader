using System;
using System.Collections.Generic;

namespace BookReader.Api.Entities;

public partial class ReadingProgress
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int BookId { get; set; }

    public int CurrentPage { get; set; }

    public decimal ProgressPercent { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual Book Book { get; set; } = null!;

    public virtual AppUser User { get; set; } = null!;
}
