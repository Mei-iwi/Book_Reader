using System;
using System.Collections.Generic;

namespace BookReader.Api.Entities;

public partial class Book
{
    public int Id { get; set; }

    public string? GoogleBookId { get; set; }

    public string Title { get; set; } = null!;

    public string? Description { get; set; }

    public string? ThumbnailUrl { get; set; }

    public string? CoverLocalPath { get; set; }

    public int PageCount { get; set; }

    public string? Language { get; set; }

    public string? PreviewLink { get; set; }

    public string? WebReaderLink { get; set; }

    public string Source { get; set; } = null!;

    public string? PdfDownloadLink { get; set; }

    public string? EpubDownloadLink { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<Bookmark> Bookmarks { get; set; } = new List<Bookmark>();

    public virtual ICollection<NoteHighlight> NoteHighlights { get; set; } = new List<NoteHighlight>();

    public virtual ICollection<ReadingProgress> ReadingProgresses { get; set; } = new List<ReadingProgress>();

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual ICollection<UserLibrary> UserLibraries { get; set; } = new List<UserLibrary>();

    public virtual ICollection<Author> Authors { get; set; } = new List<Author>();

    public virtual ICollection<Category> Categories { get; set; } = new List<Category>();
}
