using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface IAuthRepository
{
    Task<AppUser?> GetByIdAsync(int id);
    Task<AppUser?> GetByEmailAsync(string email);
    Task<List<AppUser>> GetAllAsync();
    Task<AppUser> CreateAsync(AppUser user);
    Task<AppUser> UpdateAsync(AppUser user);
    Task<bool> DeleteAsync(int id);
}
