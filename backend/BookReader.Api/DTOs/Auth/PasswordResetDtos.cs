namespace BookReader.Api.DTOs.Auth;

public class RequestPasswordResetRequest
{
    public string Email { get; set; } = null!;
}

public class VerifyPasswordResetCodeRequest
{
    public string Email { get; set; } = null!;
    public string Code { get; set; } = null!;
}

public class ResetPasswordRequest
{
    public string Email { get; set; } = null!;
    public string Code { get; set; } = null!;
    public string Password { get; set; } = null!;
    public string ConfirmPassword { get; set; } = null!;
}
