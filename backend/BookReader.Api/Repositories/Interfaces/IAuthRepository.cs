using BookReader.Api.Entities;

namespace BookReader.Api.Repositories.Interfaces;

public interface IAuthRepository
{
    Task<AppUser?> GetByEmailAsync(string email);
    Task<AppUser> CreateAsync(AppUser user);
}
