using System.ComponentModel.DataAnnotations;

namespace TimeTracker.Api.Models;

public class Project
{
    public Guid Id { get; set; }
    
    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(1000)]
    public string? Description { get; set; }
    
    [Required]
    [MaxLength(7)] // For hex color codes like #FF5733
    public string Color { get; set; } = "#007BFF";
    
    public bool IsActive { get; set; } = true;
    
    public Guid UserId { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public User User { get; set; } = null!;
    public ICollection<TimeEntry> TimeEntries { get; set; } = [];
}