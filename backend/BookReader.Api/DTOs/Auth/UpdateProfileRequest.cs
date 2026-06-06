namespace BookReader.Api.DTOs.Auth;

public class UpdateProfileRequest
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public string? AvatarUrl { get; set; }
    public string? Password { get; set; }
    public string? ConfirmPassword { get; set; }
}
