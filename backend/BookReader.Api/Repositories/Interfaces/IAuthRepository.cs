using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface IAuthRepository
{
    Task<AppUser?> GetByIdAsync(int id);
    Task<AppUser?> GetByEmailAsync(string email);
    Task<AppUser> CreateAsync(AppUser user);
    Task<AppUser> UpdateAsync(AppUser user);
}
