using BookReader.Api.DTOs.Notes;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface INoteService
{
    Task<ApiResponse<List<NoteDto>>> GetByBookAsync(int userId, int bookId);
    Task<ApiResponse<NoteDto>> AddAsync(int userId, SaveNoteRequest request);
    Task<ApiResponse<NoteDto>> UpdateAsync(int userId, int noteId, UpdateNoteRequest request);
    Task<ApiResponse<bool>> DeleteAsync(int userId, int noteId);
}
