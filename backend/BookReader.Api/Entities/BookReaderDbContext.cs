using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace BookReader.Api.Entities;

public partial class BookReaderDbContext : DbContext
{
    public BookReaderDbContext()
    {
    }

    public BookReaderDbContext(DbContextOptions<BookReaderDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<AppUser> AppUsers { get; set; }

    public virtual DbSet<Author> Authors { get; set; }

    public virtual DbSet<Book> Books { get; set; }

    public virtual DbSet<Bookmark> Bookmarks { get; set; }

    public virtual DbSet<Category> Categories { get; set; }

    public virtual DbSet<MembershipPackage> MembershipPackages { get; set; }

    public virtual DbSet<NoteHighlight> NoteHighlights { get; set; }

    public virtual DbSet<ReadingProgress> ReadingProgresses { get; set; }

    public virtual DbSet<Review> Reviews { get; set; }

    public virtual DbSet<UserLibrary> UserLibraries { get; set; }

    public virtual DbSet<UserMembership> UserMemberships { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=MEI\\SQLEXPRESS;Initial Catalog=BookReaderDb;User ID=sa;Password=123;Trust Server Certificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AppUser>(entity =>
        {
            entity.HasIndex(e => e.Email, "UX_AppUsers_Email").IsUnique();

            entity.Property(e => e.AvatarUrl).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");
            entity.Property(e => e.Email).HasMaxLength(150);
            entity.Property(e => e.FullName).HasMaxLength(150);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.PhoneNumber).HasMaxLength(20);
            entity.Property(e => e.Role)
                .HasMaxLength(30)
                .HasDefaultValue("User");
        });

        modelBuilder.Entity<Author>(entity =>
        {
            entity.HasIndex(e => e.Name, "UX_Authors_Name").IsUnique();

            entity.Property(e => e.Name).HasMaxLength(150);
        });

        modelBuilder.Entity<Book>(entity =>
        {
            entity.HasIndex(e => e.Title, "IX_Books_Title");

            entity.HasIndex(e => e.GoogleBookId, "UX_Books_GoogleBookId")
                .IsUnique()
                .HasFilter("([GoogleBookId] IS NOT NULL)");

            entity.Property(e => e.CoverLocalPath).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");
            entity.Property(e => e.EpubDownloadLink).HasMaxLength(500);
            entity.Property(e => e.GoogleBookId).HasMaxLength(100);
            entity.Property(e => e.Language).HasMaxLength(20);
            entity.Property(e => e.PdfDownloadLink).HasMaxLength(500);
            entity.Property(e => e.PreviewLink).HasMaxLength(500);
            entity.Property(e => e.Source)
                .HasMaxLength(50)
                .HasDefaultValue("local_seed");
            entity.Property(e => e.ThumbnailUrl).HasMaxLength(500);
            entity.Property(e => e.Title).HasMaxLength(300);
            entity.Property(e => e.WebReaderLink).HasMaxLength(500);

            entity.HasMany(d => d.Authors).WithMany(p => p.Books)
                .UsingEntity<Dictionary<string, object>>(
                    "BookAuthor",
                    r => r.HasOne<Author>().WithMany()
                        .HasForeignKey("AuthorId")
                        .HasConstraintName("FK_BookAuthors_Authors"),
                    l => l.HasOne<Book>().WithMany()
                        .HasForeignKey("BookId")
                        .HasConstraintName("FK_BookAuthors_Books"),
                    j =>
                    {
                        j.HasKey("BookId", "AuthorId");
                        j.ToTable("BookAuthors");
                    });

            entity.HasMany(d => d.Categories).WithMany(p => p.Books)
                .UsingEntity<Dictionary<string, object>>(
                    "BookCategory",
                    r => r.HasOne<Category>().WithMany()
                        .HasForeignKey("CategoryId")
                        .HasConstraintName("FK_BookCategories_Categories"),
                    l => l.HasOne<Book>().WithMany()
                        .HasForeignKey("BookId")
                        .HasConstraintName("FK_BookCategories_Books"),
                    j =>
                    {
                        j.HasKey("BookId", "CategoryId");
                        j.ToTable("BookCategories");
                    });
        });

        modelBuilder.Entity<Bookmark>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.BookId }, "IX_Bookmarks_UserId_BookId");

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");
            entity.Property(e => e.Note).HasMaxLength(1000);

            entity.HasOne(d => d.Book).WithMany(p => p.Bookmarks)
                .HasForeignKey(d => d.BookId)
                .HasConstraintName("FK_Bookmarks_Books");

            entity.HasOne(d => d.User).WithMany(p => p.Bookmarks)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK_Bookmarks_AppUsers");
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasIndex(e => e.Name, "UX_Categories_Name").IsUnique();

            entity.Property(e => e.Name).HasMaxLength(100);
        });

        modelBuilder.Entity<MembershipPackage>(entity =>
        {
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(100);
            entity.Property(e => e.Price).HasColumnType("decimal(18, 2)");
        });

        modelBuilder.Entity<NoteHighlight>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.BookId }, "IX_NoteHighlights_UserId_BookId");

            entity.Property(e => e.Color).HasMaxLength(30);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");

            entity.HasOne(d => d.Book).WithMany(p => p.NoteHighlights)
                .HasForeignKey(d => d.BookId)
                .HasConstraintName("FK_NoteHighlights_Books");

            entity.HasOne(d => d.User).WithMany(p => p.NoteHighlights)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK_NoteHighlights_AppUsers");
        });

        modelBuilder.Entity<ReadingProgress>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.BookId }, "UX_ReadingProgresses_UserId_BookId").IsUnique();

            entity.Property(e => e.ProgressPercent).HasColumnType("decimal(5, 2)");
            entity.Property(e => e.UpdatedAt).HasDefaultValueSql("(sysutcdatetime())");

            entity.HasOne(d => d.Book).WithMany(p => p.ReadingProgresses)
                .HasForeignKey(d => d.BookId)
                .HasConstraintName("FK_ReadingProgresses_Books");

            entity.HasOne(d => d.User).WithMany(p => p.ReadingProgresses)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK_ReadingProgresses_AppUsers");
        });

        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.BookId }, "UX_Reviews_UserId_BookId").IsUnique();

            entity.Property(e => e.Comment).HasMaxLength(1000);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");

            entity.HasOne(d => d.Book).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.BookId)
                .HasConstraintName("FK_Reviews_Books");

            entity.HasOne(d => d.User).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK_Reviews_AppUsers");
        });

        modelBuilder.Entity<UserLibrary>(entity =>
        {
            entity.HasIndex(e => e.UserId, "IX_UserLibraries_UserId");

            entity.HasIndex(e => new { e.UserId, e.BookId }, "UX_UserLibraries_UserId_BookId").IsUnique();

            entity.Property(e => e.AddedAt).HasDefaultValueSql("(sysutcdatetime())");
            entity.Property(e => e.LocalFilePath).HasMaxLength(500);

            entity.HasOne(d => d.Book).WithMany(p => p.UserLibraries)
                .HasForeignKey(d => d.BookId)
                .HasConstraintName("FK_UserLibraries_Books");

            entity.HasOne(d => d.User).WithMany(p => p.UserLibraries)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK_UserLibraries_AppUsers");
        });

        modelBuilder.Entity<UserMembership>(entity =>
        {
            entity.HasIndex(e => e.UserId, "IX_UserMemberships_UserId");

            entity.Property(e => e.Status)
                .HasMaxLength(30)
                .HasDefaultValue("Active");

            entity.HasOne(d => d.MembershipPackage).WithMany(p => p.UserMemberships)
                .HasForeignKey(d => d.MembershipPackageId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserMemberships_MembershipPackages");

            entity.HasOne(d => d.User).WithMany(p => p.UserMemberships)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK_UserMemberships_AppUsers");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
