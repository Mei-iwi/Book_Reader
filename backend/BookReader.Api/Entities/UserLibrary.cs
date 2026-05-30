using System;
using System.Collections.Generic;

namespace BookReader.Api.Entities;

public partial class UserLibrary
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int BookId { get; set; }

    public bool IsFavorite { get; set; }

    public bool IsDownloaded { get; set; }

    public string? LocalFilePath { get; set; }

    public DateTime AddedAt { get; set; }

    public DateTime? DownloadedAt { get; set; }

    public virtual Book Book { get; set; } = null!;

    public virtual AppUser User { get; set; } = null!;
}
