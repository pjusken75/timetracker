namespace TimeTracker.Api.DTOs;

public class TimeEntryDto
{
    public Guid Id { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public string? Description { get; set; }
    public bool IsRunning { get; set; }
    public Guid UserId { get; set; }
    public Guid? ProjectId { get; set; }
    public ProjectDto? Project { get; set; }
    public TimeSpan? Duration { get; set; }
    public decimal? DurationInHours { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class CreateTimeEntryDto
{
    public DateTime StartTime { get; set; }
    public string? Description { get; set; }
    public Guid? ProjectId { get; set; }
}

public class UpdateTimeEntryDto
{
    public DateTime StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public string? Description { get; set; }
    public Guid? ProjectId { get; set; }
}

public class StartTimeEntryDto
{
    public string? Description { get; set; }
    public Guid? ProjectId { get; set; }
}

public class StopTimeEntryDto
{
    public DateTime EndTime { get; set; }
}