using AutoMapper;
using TimeTracker.Api.DTOs;
using TimeTracker.Api.Models;

namespace TimeTracker.Api.Mappings;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // User mappings
        CreateMap<User, UserDto>();
        CreateMap<CreateUserDto, User>();
        CreateMap<UpdateUserDto, User>()
            .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
        
        // Project mappings
        CreateMap<Project, ProjectDto>();
        CreateMap<CreateProjectDto, Project>();
        CreateMap<UpdateProjectDto, Project>()
            .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
        
        // TimeEntry mappings
        CreateMap<TimeEntry, TimeEntryDto>()
            .ForMember(dest => dest.Duration, opt => opt.MapFrom(src => src.Duration))
            .ForMember(dest => dest.DurationInHours, opt => opt.MapFrom(src => src.DurationInHours));
        CreateMap<CreateTimeEntryDto, TimeEntry>();
        CreateMap<UpdateTimeEntryDto, TimeEntry>()
            .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
        CreateMap<StartTimeEntryDto, TimeEntry>()
            .ForMember(dest => dest.StartTime, opt => opt.MapFrom(src => DateTime.UtcNow))
            .ForMember(dest => dest.IsRunning, opt => opt.MapFrom(src => true));
    }
}