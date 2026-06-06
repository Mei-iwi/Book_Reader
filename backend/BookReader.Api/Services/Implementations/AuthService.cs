using BookReader.Api.DTOs.Auth;
using BookReader.Api.Entities;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Interfaces;

namespace BookReader.Api.Services.Implementations;

public class AuthService : IAuthService
{
    private readonly IAuthRepository _authRepository;
    private readonly JwtHelper _jwtHelper;

    public AuthService(IAuthRepository authRepository, JwtHelper jwtHelper)
    {
        _authRepository = authRepository;
        _jwtHelper = jwtHelper;
    }

    public async Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.FullName))
        {
            return ApiResponse<AuthResponse>.Fail("Full name is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return ApiResponse<AuthResponse>.Fail("Email is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Password))
        {
            return ApiResponse<AuthResponse>.Fail("Password is required.");
        }

        if (request.Password != request.ConfirmPassword)
        {
            return ApiResponse<AuthResponse>.Fail("Confirm password does not match.");
        }

        var email = request.Email.Trim();
        var existingUser = await _authRepository.GetByEmailAsync(email);
        if (existingUser != null)
        {
            return ApiResponse<AuthResponse>.Fail("Email already exists.");
        }

        var user = new AppUser
        {
            FullName = request.FullName.Trim(),
            Email = email,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = PasswordHasher.Hash(request.Password),
            Role = "User",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        await _authRepository.CreateAsync(user);
        return ApiResponse<AuthResponse>.Ok(ToAuthResponse(user), "Register successfully.");
    }

    public async Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
        {
            return ApiResponse<AuthResponse>.Fail("Email and password are required.");
        }

        var user = await _authRepository.GetByEmailAsync(request.Email.Trim());
        if (user == null || !PasswordHasher.Verify(request.Password, user.PasswordHash))
        {
            return ApiResponse<AuthResponse>.Fail("Invalid email or password.");
        }

        if (!user.IsActive)
        {
            return ApiResponse<AuthResponse>.Fail("User is inactive.");
        }

        return ApiResponse<AuthResponse>.Ok(ToAuthResponse(user), "Login successfully.");
    }

    public async Task<ApiResponse<AuthResponse>> GetMeAsync(string token)
    {
        var userId = _jwtHelper.GetUserIdFromToken(token);
        if (userId == null)
        {
            return ApiResponse<AuthResponse>.Fail("Invalid token.");
        }

        var user = await _authRepository.GetByIdAsync(userId.Value);
        if (user == null || !user.IsActive)
        {
            return ApiResponse<AuthResponse>.Fail("User not found.");
        }

        return ApiResponse<AuthResponse>.Ok(ToAuthResponse(user));
    }

    public async Task<ApiResponse<AuthResponse>> UpdateProfileAsync(string token, UpdateProfileRequest request)
    {
        var userId = _jwtHelper.GetUserIdFromToken(token);
        if (userId == null)
        {
            return ApiResponse<AuthResponse>.Fail("Invalid token.");
        }

        var user = await _authRepository.GetByIdAsync(userId.Value);
        if (user == null || !user.IsActive)
        {
            return ApiResponse<AuthResponse>.Fail("User not found.");
        }

        if (string.IsNullOrWhiteSpace(request.FullName))
        {
            return ApiResponse<AuthResponse>.Fail("Full name is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return ApiResponse<AuthResponse>.Fail("Email is required.");
        }

        var email = request.Email.Trim();
        var existingUser = await _authRepository.GetByEmailAsync(email);
        if (existingUser != null && existingUser.Id != user.Id)
        {
            return ApiResponse<AuthResponse>.Fail("Email already exists.");
        }

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            if (request.Password != request.ConfirmPassword)
            {
                return ApiResponse<AuthResponse>.Fail("Confirm password does not match.");
            }

            user.PasswordHash = PasswordHasher.Hash(request.Password);
        }

        user.FullName = request.FullName.Trim();
        user.Email = email;
        user.PhoneNumber = request.PhoneNumber;
        user.AvatarUrl = request.AvatarUrl;
        user.UpdatedAt = DateTime.UtcNow;

        await _authRepository.UpdateAsync(user);
        return ApiResponse<AuthResponse>.Ok(ToAuthResponse(user), "Profile updated successfully.");
    }

    private AuthResponse ToAuthResponse(AppUser user)
    {
        return new AuthResponse
        {
            Token = _jwtHelper.GenerateToken(user),
            UserId = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            AvatarUrl = user.AvatarUrl,
            Role = user.Role
        };
    }
}
