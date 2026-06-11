using BookReader.Api.DTOs.Auth;
using BookReader.Api.Helpers;

namespace BookReader.Api.Services.Interfaces;

public interface IAuthService
{
    Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request);
    Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request);
    Task<ApiResponse<AuthResponse>> GetMeAsync(string token);
    Task<ApiResponse<AuthResponse>> UpdateProfileAsync(string token, UpdateProfileRequest request);
    Task<ApiResponse<object>> RequestPasswordResetAsync(RequestPasswordResetRequest request);
    Task<ApiResponse<object>> VerifyPasswordResetCodeAsync(VerifyPasswordResetCodeRequest request);
    Task<ApiResponse<object>> ResetPasswordAsync(ResetPasswordRequest request);
    Task<ApiResponse<List<AdminUserDto>>> AdminGetUsersAsync(string token);
    Task<ApiResponse<AdminUserDto>> AdminCreateUserAsync(string token, AdminCreateUserRequest request);
    Task<ApiResponse<AdminUserDto>> AdminUpdateUserAsync(string token, int userId, AdminUpdateUserRequest request);
    Task<ApiResponse<bool>> AdminDeleteUserAsync(string token, int userId);
}
