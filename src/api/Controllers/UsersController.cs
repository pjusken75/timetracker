using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AutoMapper;
using TimeTracker.Api.Data;
using TimeTracker.Api.Models;
using TimeTracker.Api.DTOs;
using System.Security.Claims;

namespace TimeTracker.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize] // Require authentication for all endpoints
public class UsersController : ControllerBase
{
    private readonly TimeTrackerDbContext _context;
    private readonly IMapper _mapper;
    private readonly ILogger<UsersController> _logger;

    public UsersController(
        TimeTrackerDbContext context, 
        IMapper mapper,
        ILogger<UsersController> logger)
    {
        _context = context;
        _mapper = mapper;
        _logger = logger;
    }

    /// <summary>
    /// Test endpoint to list all users (temporary - no auth required)
    /// </summary>
    [HttpGet("test")]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<UserDto>>> GetUsersTest()
    {
        var users = await _context.Users
            .Where(u => u.IsActive)
            .OrderBy(u => u.FirstName)
            .ThenBy(u => u.LastName)
            .ToListAsync();

        return Ok(_mapper.Map<IEnumerable<UserDto>>(users));
    }

    /// <summary>
    /// Get current user's profile
    /// </summary>
    [HttpGet("me")]
    public async Task<ActionResult<UserDto>> GetCurrentUser()
    {
        var userEmail = GetCurrentUserEmail();
        if (string.IsNullOrEmpty(userEmail))
        {
            return Unauthorized("User email not found in claims");
        }

        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == userEmail);

        if (user == null)
        {
            // Auto-create user if they exist in Azure AD B2C but not in our database
            user = await CreateUserFromClaims();
        }

        return Ok(_mapper.Map<UserDto>(user));
    }

    /// <summary>
    /// Update current user's profile
    /// </summary>
    [HttpPut("me")]
    public async Task<ActionResult<UserDto>> UpdateCurrentUser(UpdateUserDto updateUserDto)
    {
        var userEmail = GetCurrentUserEmail();
        if (string.IsNullOrEmpty(userEmail))
        {
            return Unauthorized("User email not found in claims");
        }

        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == userEmail);

        if (user == null)
        {
            return NotFound("User not found");
        }

        // Update user properties
        user.FirstName = updateUserDto.FirstName ?? user.FirstName;
        user.LastName = updateUserDto.LastName ?? user.LastName;
        user.TimeZone = updateUserDto.TimeZone ?? user.TimeZone;
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        _logger.LogInformation("User {Email} updated their profile", userEmail);

        return Ok(_mapper.Map<UserDto>(user));
    }

    /// <summary>
    /// Get all users (admin functionality - can be restricted later)
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserDto>>> GetUsers()
    {
        var users = await _context.Users
            .Where(u => u.IsActive)
            .OrderBy(u => u.FirstName)
            .ThenBy(u => u.LastName)
            .ToListAsync();

        return Ok(_mapper.Map<IEnumerable<UserDto>>(users));
    }

    /// <summary>
    /// Get user by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<UserDto>> GetUser(Guid id)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == id && u.IsActive);

        if (user == null)
        {
            return NotFound();
        }

        return Ok(_mapper.Map<UserDto>(user));
    }

    /// <summary>
    /// Deactivate current user's account
    /// </summary>
    [HttpDelete("me")]
    public async Task<IActionResult> DeactivateCurrentUser()
    {
        var userEmail = GetCurrentUserEmail();
        if (string.IsNullOrEmpty(userEmail))
        {
            return Unauthorized("User email not found in claims");
        }

        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == userEmail);

        if (user == null)
        {
            return NotFound("User not found");
        }

        // Soft delete - mark as inactive
        user.IsActive = false;
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        _logger.LogInformation("User {Email} deactivated their account", userEmail);

        return NoContent();
    }

    private string? GetCurrentUserEmail()
    {
        return User.FindFirst(ClaimTypes.Email)?.Value ?? 
               User.FindFirst("emails")?.Value ??
               User.FindFirst("preferred_username")?.Value;
    }

    private string? GetCurrentUserName()
    {
        return User.FindFirst(ClaimTypes.Name)?.Value ??
               User.FindFirst("name")?.Value;
    }

    private string? GetCurrentUserGivenName()
    {
        return User.FindFirst(ClaimTypes.GivenName)?.Value ??
               User.FindFirst("given_name")?.Value;
    }

    private string? GetCurrentUserSurname()
    {
        return User.FindFirst(ClaimTypes.Surname)?.Value ??
               User.FindFirst("family_name")?.Value;
    }

    private async Task<User> CreateUserFromClaims()
    {
        var email = GetCurrentUserEmail();
        var givenName = GetCurrentUserGivenName();
        var surname = GetCurrentUserSurname();
        var name = GetCurrentUserName();

        // Parse name if given name/surname not available
        if (string.IsNullOrEmpty(givenName) && !string.IsNullOrEmpty(name))
        {
            var nameParts = name.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            givenName = nameParts.FirstOrDefault() ?? "";
            surname = nameParts.Length > 1 ? string.Join(" ", nameParts.Skip(1)) : "";
        }

        var user = new User
        {
            Email = email ?? throw new InvalidOperationException("Email is required"),
            FirstName = givenName ?? "Unknown",
            LastName = surname ?? "User",
            TimeZone = "UTC", // Default timezone
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Auto-created user {Email} from Azure AD B2C claims", email);

        return user;
    }
}