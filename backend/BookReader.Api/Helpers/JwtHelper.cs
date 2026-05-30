using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BookReader.Api.Entities;
using Microsoft.IdentityModel.Tokens;

namespace BookReader.Api.Helpers;

public class JwtHelper
{
    private readonly IConfiguration _configuration;

    public JwtHelper(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public string GenerateToken(AppUser user)
    {
        var key = _configuration["Jwt:Key"] ?? "BookReaderDevelopmentSecretKey123456";
        var issuer = _configuration["Jwt:Issuer"] ?? "BookReader.Api";
        var audience = _configuration["Jwt:Audience"] ?? "BookReader.Flutter";
        var expiresInDays = int.TryParse(_configuration["Jwt:ExpiresInDays"], out var days) ? days : 7;

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.FullName),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role)
        };

        var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(issuer, audience, claims, DateTime.UtcNow, DateTime.UtcNow.AddDays(expiresInDays), credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public int? GetUserIdFromToken(string token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return null;
        }

        var key = _configuration["Jwt:Key"] ?? "BookReaderDevelopmentSecretKey123456";
        var issuer = _configuration["Jwt:Issuer"] ?? "BookReader.Api";
        var audience = _configuration["Jwt:Audience"] ?? "BookReader.Flutter";

        var validationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            ValidateIssuer = true,
            ValidIssuer = issuer,
            ValidateAudience = true,
            ValidAudience = audience,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };

        try
        {
            var principal = new JwtSecurityTokenHandler().ValidateToken(token, validationParameters, out _);
            var userIdValue = principal.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(userIdValue, out var userId) ? userId : null;
        }
        catch
        {
            return null;
        }
    }
}
