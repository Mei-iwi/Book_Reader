using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface INoteRepository
{
    Task<List<NoteHighlight>> GetByBookAsync(int userId, int bookId);
    Task<NoteHighlight> AddAsync(NoteHighlight note);
    Task<bool> DeleteAsync(int userId, int noteId);
}
