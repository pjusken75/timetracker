using System.ComponentModel.DataAnnotations;

namespace TimeTracker.Api.Models;

public class TimeEntry
{
    public Guid Id { get; set; }
    
    public DateTime StartTime { get; set; }
    
    public DateTime? EndTime { get; set; }
    
    [MaxLength(500)]
    public string? Description { get; set; }
    
    public bool IsRunning { get; set; } = false;
    
    public Guid UserId { get; set; }
    
    public Guid? ProjectId { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Calculated properties
    public TimeSpan? Duration => EndTime.HasValue ? EndTime.Value - StartTime : null;
    
    public decimal? DurationInHours => Duration?.TotalHours > 0 ? (decimal)Duration.Value.TotalHours : null;
    
    // Navigation properties
    public User User { get; set; } = null!;
    public Project? Project { get; set; }
}