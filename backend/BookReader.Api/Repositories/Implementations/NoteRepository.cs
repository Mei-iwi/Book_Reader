using BookReader.Api.Data;
using BookReader.Api.Entities;
using BookReader.Api.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BookReader.Api.Repositories.Implementations;

public class NoteRepository : INoteRepository
{
    private readonly BookReaderDbContext _context;

    public NoteRepository(BookReaderDbContext context)
    {
        _context = context;
    }

    public async Task<List<NoteHighlight>> GetByBookAsync(int userId, int bookId)
    {
        return await _context.NoteHighlights
            .Where(x => x.UserId == userId && x.BookId == bookId)
            .OrderBy(x => x.Page)
            .ToListAsync();
    }

    public async Task<NoteHighlight> AddAsync(NoteHighlight note)
    {
        _context.NoteHighlights.Add(note);
        await _context.SaveChangesAsync();
        return note;
    }

    public async Task<NoteHighlight?> UpdateAsync(int userId, int noteId, int page, string? selectedText, string? noteContent, string? color)
    {
        var note = await _context.NoteHighlights.FirstOrDefaultAsync(x => x.UserId == userId && x.Id == noteId);
        if (note == null)
        {
            return null;
        }

        note.Page = page;
        note.SelectedText = selectedText;
        note.NoteContent = noteContent;
        note.Color = color;
        note.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return note;
    }

    public async Task<bool> DeleteAsync(int userId, int noteId)
    {
        var note = await _context.NoteHighlights.FirstOrDefaultAsync(x => x.UserId == userId && x.Id == noteId);
        if (note == null)
        {
            return false;
        }

        _context.NoteHighlights.Remove(note);
        await _context.SaveChangesAsync();
        return true;
    }
}
