using BookReader.Api.DTOs.Auth;
using BookReader.Api.Entities;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Interfaces;
using System.Collections.Concurrent;
using System.Net;
using System.Net.Mail;
using System.Security.Cryptography;

namespace BookReader.Api.Services.Implementations;

public class AuthService : IAuthService
{
    private sealed record PasswordResetCode(string Code, DateTime ExpiresAtUtc);

    private static readonly ConcurrentDictionary<string, PasswordResetCode> PasswordResetCodes = new();

    private readonly IAuthRepository _authRepository;
    private readonly JwtHelper _jwtHelper;
    private readonly IConfiguration _configuration;

    public AuthService(
        IAuthRepository authRepository,
        JwtHelper jwtHelper,
        IConfiguration configuration)
    {
        _authRepository = authRepository;
        _jwtHelper = jwtHelper;
        _configuration = configuration;
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

    public async Task<ApiResponse<object>> RequestPasswordResetAsync(RequestPasswordResetRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return ApiResponse<object>.Fail("Email is required.");
        }

        var email = request.Email.Trim();
        var user = await _authRepository.GetByEmailAsync(email);
        if (user == null || !user.IsActive)
        {
            return ApiResponse<object>.Fail("Email is not registered.");
        }

        var code = RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");
        PasswordResetCodes[email.ToLowerInvariant()] = new PasswordResetCode(
            code,
            DateTime.UtcNow.AddMinutes(10));

        try
        {
            await SendPasswordResetEmailAsync(email, user.FullName, code);
        }
        catch (SmtpException ex)
        {
            PasswordResetCodes.TryRemove(email.ToLowerInvariant(), out _);
            if (ex.Message.Contains("5.7.0", StringComparison.OrdinalIgnoreCase) ||
                ex.Message.Contains("not authenticated", StringComparison.OrdinalIgnoreCase) ||
                ex.Message.Contains("Authentication Required", StringComparison.OrdinalIgnoreCase))
            {
                return ApiResponse<object>.Fail(
                    "Gmail tu choi dang nhap SMTP. Hay tao lai App Password cho c2005vn@gmail.com, bat 2-Step Verification, roi cap nhat SMTP_PASSWORD trong file .env.");
            }

            return ApiResponse<object>.Fail(
                $"Khong the gui email xac thuc qua Gmail SMTP: {ex.Message}");
        }
        catch (InvalidOperationException ex)
        {
            PasswordResetCodes.TryRemove(email.ToLowerInvariant(), out _);
            return ApiResponse<object>.Fail(ex.Message);
        }

        return ApiResponse<object>.Ok(null!, "Password reset code sent.");
    }

    public Task<ApiResponse<object>> VerifyPasswordResetCodeAsync(VerifyPasswordResetCodeRequest request)
    {
        var validation = ValidatePasswordResetCode(request.Email, request.Code);
        return Task.FromResult(validation
            ? ApiResponse<object>.Ok(null!, "Password reset code is valid.")
            : ApiResponse<object>.Fail("Invalid or expired verification code."));
    }

    public async Task<ApiResponse<object>> ResetPasswordAsync(ResetPasswordRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Password))
        {
            return ApiResponse<object>.Fail("Password is required.");
        }

        if (request.Password != request.ConfirmPassword)
        {
            return ApiResponse<object>.Fail("Confirm password does not match.");
        }

        if (!ValidatePasswordResetCode(request.Email, request.Code))
        {
            return ApiResponse<object>.Fail("Invalid or expired verification code.");
        }

        var email = request.Email.Trim();
        var user = await _authRepository.GetByEmailAsync(email);
        if (user == null || !user.IsActive)
        {
            return ApiResponse<object>.Fail("User not found.");
        }

        user.PasswordHash = PasswordHasher.Hash(request.Password);
        user.UpdatedAt = DateTime.UtcNow;
        await _authRepository.UpdateAsync(user);
        PasswordResetCodes.TryRemove(email.ToLowerInvariant(), out _);

        return ApiResponse<object>.Ok(null!, "Password updated successfully.");
    }

    public async Task<ApiResponse<List<AdminUserDto>>> AdminGetUsersAsync(string token)
    {
        var admin = await GetAdminFromTokenAsync(token);
        if (admin == null)
        {
            return ApiResponse<List<AdminUserDto>>.Fail("Admin permission is required.");
        }

        var users = await _authRepository.GetAllAsync();
        return ApiResponse<List<AdminUserDto>>.Ok(users.Select(ToAdminUserDto).ToList());
    }

    public async Task<ApiResponse<AdminUserDto>> AdminCreateUserAsync(
        string token,
        AdminCreateUserRequest request)
    {
        var admin = await GetAdminFromTokenAsync(token);
        if (admin == null)
        {
            return ApiResponse<AdminUserDto>.Fail("Admin permission is required.");
        }

        if (string.IsNullOrWhiteSpace(request.FullName))
        {
            return ApiResponse<AdminUserDto>.Fail("Full name is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return ApiResponse<AdminUserDto>.Fail("Email is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Password))
        {
            return ApiResponse<AdminUserDto>.Fail("Password is required.");
        }

        if (request.Password != request.ConfirmPassword)
        {
            return ApiResponse<AdminUserDto>.Fail("Confirm password does not match.");
        }

        var email = request.Email.Trim();
        var existing = await _authRepository.GetByEmailAsync(email);
        if (existing != null)
        {
            return ApiResponse<AdminUserDto>.Fail("Email already exists.");
        }

        var user = new AppUser
        {
            FullName = request.FullName.Trim(),
            Email = email,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = PasswordHasher.Hash(request.Password),
            Role = NormalizeRole(request.Role),
            IsActive = request.IsActive,
            CreatedAt = DateTime.UtcNow
        };

        await _authRepository.CreateAsync(user);
        return ApiResponse<AdminUserDto>.Ok(ToAdminUserDto(user), "User created.");
    }

    public async Task<ApiResponse<AdminUserDto>> AdminUpdateUserAsync(
        string token,
        int userId,
        AdminUpdateUserRequest request)
    {
        var admin = await GetAdminFromTokenAsync(token);
        if (admin == null)
        {
            return ApiResponse<AdminUserDto>.Fail("Admin permission is required.");
        }

        var user = await _authRepository.GetByIdAsync(userId);
        if (user == null)
        {
            return ApiResponse<AdminUserDto>.Fail("User not found.");
        }

        if (string.IsNullOrWhiteSpace(request.FullName))
        {
            return ApiResponse<AdminUserDto>.Fail("Full name is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return ApiResponse<AdminUserDto>.Fail("Email is required.");
        }

        var email = request.Email.Trim();
        var existing = await _authRepository.GetByEmailAsync(email);
        if (existing != null && existing.Id != user.Id)
        {
            return ApiResponse<AdminUserDto>.Fail("Email already exists.");
        }

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            if (request.Password != request.ConfirmPassword)
            {
                return ApiResponse<AdminUserDto>.Fail("Confirm password does not match.");
            }

            user.PasswordHash = PasswordHasher.Hash(request.Password);
        }

        user.FullName = request.FullName.Trim();
        user.Email = email;
        user.PhoneNumber = request.PhoneNumber;
        user.AvatarUrl = request.AvatarUrl;
        user.Role = user.Id == admin.Id ? "Admin" : NormalizeRole(request.Role);
        user.IsActive = user.Id == admin.Id ? true : request.IsActive;
        user.UpdatedAt = DateTime.UtcNow;

        await _authRepository.UpdateAsync(user);
        return ApiResponse<AdminUserDto>.Ok(ToAdminUserDto(user), "User updated.");
    }

    public async Task<ApiResponse<bool>> AdminDeleteUserAsync(string token, int userId)
    {
        var admin = await GetAdminFromTokenAsync(token);
        if (admin == null)
        {
            return ApiResponse<bool>.Fail("Admin permission is required.");
        }

        if (admin.Id == userId)
        {
            return ApiResponse<bool>.Fail("Admin cannot delete current account.");
        }

        var deleted = await _authRepository.DeleteAsync(userId);
        return deleted
            ? ApiResponse<bool>.Ok(true, "User deleted.")
            : ApiResponse<bool>.Fail("User not found.");
    }

    private bool ValidatePasswordResetCode(string? email, string? code)
    {
        if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(code))
        {
            return false;
        }

        var key = email.Trim().ToLowerInvariant();
        if (!PasswordResetCodes.TryGetValue(key, out var savedCode))
        {
            return false;
        }

        if (savedCode.ExpiresAtUtc < DateTime.UtcNow)
        {
            PasswordResetCodes.TryRemove(key, out _);
            return false;
        }

        return savedCode.Code == code.Trim();
    }

    private async Task<AppUser?> GetAdminFromTokenAsync(string token)
    {
        var userId = _jwtHelper.GetUserIdFromToken(token);
        if (userId == null)
        {
            return null;
        }

        var user = await _authRepository.GetByIdAsync(userId.Value);
        if (user == null || !user.IsActive || !string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        return user;
    }

    private static string NormalizeRole(string? role)
    {
        return string.Equals(role?.Trim(), "Admin", StringComparison.OrdinalIgnoreCase)
            ? "Admin"
            : "User";
    }

    private static AdminUserDto ToAdminUserDto(AppUser user)
    {
        return new AdminUserDto
        {
            UserId = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            AvatarUrl = user.AvatarUrl,
            Role = user.Role,
            IsActive = user.IsActive,
            CreatedAt = user.CreatedAt,
            UpdatedAt = user.UpdatedAt
        };
    }

    private async Task SendPasswordResetEmailAsync(string toEmail, string fullName, string code)
    {
        var section = _configuration.GetSection("Smtp");
        var host = section["Host"] ?? "smtp.gmail.com";
        var port = section.GetValue("Port", 587);
        var userName = section["UserName"]?.Trim();
        var password =
            Environment.GetEnvironmentVariable("SMTP_PASSWORD") ??
            section["Password"];
        password = password?.Replace(" ", string.Empty);
        var fromName = section["FromName"] ?? "Book Reader";

        if (string.IsNullOrWhiteSpace(userName) || string.IsNullOrWhiteSpace(password))
        {
            throw new InvalidOperationException("SMTP username or password is not configured.");
        }

        using var message = new MailMessage
        {
            From = new MailAddress(userName, fromName),
            Subject = "Ma xac thuc doi mat khau Book Reader",
            Body = $"""
                Xin chao {fullName},

                Ma xac thuc doi mat khau cua ban la: {code}
                Ma nay co hieu luc trong 10 phut.

                Neu ban khong yeu cau doi mat khau, vui long bo qua email nay.
                """,
            IsBodyHtml = false
        };
        message.To.Add(toEmail);

        using var client = new SmtpClient(host, port)
        {
            DeliveryMethod = SmtpDeliveryMethod.Network,
            EnableSsl = true,
            Timeout = 15000,
            UseDefaultCredentials = false,
            Credentials = new NetworkCredential(userName, password)
        };

        await client.SendMailAsync(message);
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
