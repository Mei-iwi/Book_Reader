using BookReader.Api.DTOs.Auth;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface IAuthService
{
    Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request);
    Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request);
    Task<ApiResponse<AuthResponse>> GetMeAsync(string token);
}
