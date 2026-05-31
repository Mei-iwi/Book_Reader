using System;
using System.Collections.Generic;

namespace BookReader.Api.Entities;

public partial class AppUser
{
    public int Id { get; set; }

    public string FullName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? PhoneNumber { get; set; }

    public string PasswordHash { get; set; } = null!;

    public string? AvatarUrl { get; set; }

    public string Role { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<Bookmark> Bookmarks { get; set; } = new List<Bookmark>();

    public virtual ICollection<NoteHighlight> NoteHighlights { get; set; } = new List<NoteHighlight>();

    public virtual ICollection<ReadingProgress> ReadingProgresses { get; set; } = new List<ReadingProgress>();

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual ICollection<UserLibrary> UserLibraries { get; set; } = new List<UserLibrary>();

    public virtual ICollection<UserMembership> UserMemberships { get; set; } = new List<UserMembership>();
}
