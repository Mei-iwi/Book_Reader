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

    private async Task<IActionResult> UpdateProfileFromBearerToken(UpdateProfileRequest request)
    {
        var authorizationHeader = Request.Headers.Authorization.ToString();
        if (string.IsNullOrWhiteSpace(authorizationHeader) || !authorizationHeader.StartsWith("Bearer "))
        {
            return Unauthorized(BookReader.Api.Helpers.ApiResponse<AuthResponse>.Fail("Missing bearer token."));
        }

        var token = authorizationHeader["Bearer ".Length..].Trim();
        var result = await _authService.UpdateProfileAsync(token, request);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}
