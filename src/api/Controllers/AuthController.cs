using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace TimeTracker.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly ILogger<AuthController> _logger;

    public AuthController(ILogger<AuthController> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Test endpoint to check authentication status
    /// </summary>
    [HttpGet("status")]
    [AllowAnonymous]
    public ActionResult<object> GetAuthStatus()
    {
        var isAuthenticated = User.Identity?.IsAuthenticated ?? false;
        
        var claims = User.Claims.Select(c => new { c.Type, c.Value }).ToList();
        
        return Ok(new
        {
            IsAuthenticated = isAuthenticated,
            UserName = User.Identity?.Name,
            Claims = claims,
            Timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Get current user information from claims
    /// </summary>
    [HttpGet("me")]
    [AllowAnonymous]
    public ActionResult<object> GetCurrentUserInfo()
    {
        if (!User.Identity?.IsAuthenticated ?? true)
        {
            return Ok(new { IsAuthenticated = false, Message = "User not authenticated" });
        }

        var email = User.FindFirst("emails")?.Value ?? 
                   User.FindFirst("preferred_username")?.Value ??
                   User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;

        var name = User.FindFirst("name")?.Value ??
                  User.FindFirst(System.Security.Claims.ClaimTypes.Name)?.Value;

        var givenName = User.FindFirst("given_name")?.Value ??
                       User.FindFirst(System.Security.Claims.ClaimTypes.GivenName)?.Value;

        var familyName = User.FindFirst("family_name")?.Value ??
                        User.FindFirst(System.Security.Claims.ClaimTypes.Surname)?.Value;

        return Ok(new
        {
            IsAuthenticated = true,
            Email = email,
            Name = name,
            GivenName = givenName,
            FamilyName = familyName,
            UserId = User.FindFirst("sub")?.Value ?? User.FindFirst("oid")?.Value,
            AllClaims = User.Claims.Select(c => new { c.Type, c.Value }).ToList()
        });
    }
}