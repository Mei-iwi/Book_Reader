using BookReader.Api.DTOs.Auth;
using BookReader.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BookReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest request)
    {
        var result = await _authService.RegisterAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        var result = await _authService.LoginAsync(request);
        return result.Success ? Ok(result) : Unauthorized(result);
    }

    [HttpPost("request-password-reset")]
    public async Task<IActionResult> RequestPasswordReset(RequestPasswordResetRequest request)
    {
        var result = await _authService.RequestPasswordResetAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpPost("verify-password-reset-code")]
    public async Task<IActionResult> VerifyPasswordResetCode(VerifyPasswordResetCodeRequest request)
    {
        var result = await _authService.VerifyPasswordResetCodeAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword(ResetPasswordRequest request)
    {
        var result = await _authService.ResetPasswordAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpGet("me")]
    public async Task<IActionResult> Me()
    {
        var authorizationHeader = Request.Headers.Authorization.ToString();
        if (string.IsNullOrWhiteSpace(authorizationHeader) || !authorizationHeader.StartsWith("Bearer "))
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<AuthResponse>.Fail("Missing bearer token."));
        }

        var token = authorizationHeader["Bearer ".Length..].Trim();
        var result = await _authService.GetMeAsync(token);
        return result.Success ? Ok(result) : Unauthorized(result);
    }

    [HttpPut("me")]
    public async Task<IActionResult> UpdateMe(UpdateProfileRequest request)
    {
        return await UpdateProfileFromBearerToken(request);
    }

    [HttpPost("me")]
    public async Task<IActionResult> UpdateMePost(UpdateProfileRequest request)
    {
        return await UpdateProfileFromBearerToken(request);
    }

    [HttpGet("admin/users")]
    public async Task<IActionResult> AdminGetUsers()
    {
        var token = GetBearerToken();
        if (token == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<List<AdminUserDto>>.Fail("Missing bearer token."));
        }

        var result = await _authService.AdminGetUsersAsync(token);
        return result.Success ? Ok(result) : Unauthorized(result);
    }

    [HttpPost("admin/users")]
    public async Task<IActionResult> AdminCreateUser(AdminCreateUserRequest request)
    {
        var token = GetBearerToken();
        if (token == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<AdminUserDto>.Fail("Missing bearer token."));
        }

        var result = await _authService.AdminCreateUserAsync(token, request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpPut("admin/users/{userId:int}")]
    public async Task<IActionResult> AdminUpdateUser(int userId, AdminUpdateUserRequest request)
    {
        var token = GetBearerToken();
        if (token == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<AdminUserDto>.Fail("Missing bearer token."));
        }

        var result = await _authService.AdminUpdateUserAsync(token, userId, request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("admin/users/{userId:int}")]
    public async Task<IActionResult> AdminDeleteUser(int userId)
    {
        var token = GetBearerToken();
        if (token == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<bool>.Fail("Missing bearer token."));
        }

        var result = await _authService.AdminDeleteUserAsync(token, userId);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    private async Task<IActionResult> UpdateProfileFromBearerToken(UpdateProfileRequest request)
    {
        var token = GetBearerToken();
        if (token == null)
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<AuthResponse>.Fail("Missing bearer token."));
        }

        var result = await _authService.UpdateProfileAsync(token, request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    private string? GetBearerToken()
    {
        var authorizationHeader = Request.Headers.Authorization.ToString();
        if (string.IsNullOrWhiteSpace(authorizationHeader) || !authorizationHeader.StartsWith("Bearer "))
        {
            return null;
        }

        return authorizationHeader["Bearer ".Length..].Trim();
    }
}
