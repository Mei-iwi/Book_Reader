using BookReader.Api.DTOs.Notes;
using BookReader.Api.Entities;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Interfaces;

namespace BookReader.Api.Services.Implementations;

public class NoteService : INoteService
{
    private readonly INoteRepository _noteRepository;

    public NoteService(INoteRepository noteRepository)
    {
        _noteRepository = noteRepository;
    }

    public async Task<ApiResponse<List<NoteDto>>> GetByBookAsync(int userId, int bookId)
    {
        var notes = await _noteRepository.GetByBookAsync(userId, bookId);
        return ApiResponse<List<NoteDto>>.Ok(notes.Select(ToDto).ToList());
    }

    public async Task<ApiResponse<NoteDto>> AddAsync(SaveNoteRequest request)
    {
        var note = new NoteHighlight
        {
            UserId = request.UserId,
            BookId = request.BookId,
            Page = request.Page,
            SelectedText = request.SelectedText,
            NoteContent = request.NoteContent,
            Color = request.Color,
            CreatedAt = DateTime.UtcNow
        };

        var created = await _noteRepository.AddAsync(note);
        return ApiResponse<NoteDto>.Ok(ToDto(created), "Note saved.");
    }

    public async Task<ApiResponse<bool>> DeleteAsync(int userId, int noteId)
    {
        var deleted = await _noteRepository.DeleteAsync(userId, noteId);
        return deleted
            ? ApiResponse<bool>.Ok(true, "Note deleted.")
            : ApiResponse<bool>.Fail("Note not found.");
    }

    private static NoteDto ToDto(NoteHighlight note)
    {
        return new NoteDto
        {
            Id = note.Id,
            UserId = note.UserId,
            BookId = note.BookId,
            Page = note.Page,
            SelectedText = note.SelectedText,
            NoteContent = note.NoteContent,
            Color = note.Color,
            CreatedAt = note.CreatedAt
        };
    }
}
