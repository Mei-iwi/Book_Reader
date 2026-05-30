using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface INoteRepository
{
    Task<List<NoteHighlight>> GetByBookAsync(int userId, int bookId);
    Task<NoteHighlight> AddAsync(NoteHighlight note);
    Task<NoteHighlight?> UpdateAsync(int userId, int noteId, int page, string? selectedText, string? noteContent, string? color);
    Task<bool> DeleteAsync(int userId, int noteId);
}
