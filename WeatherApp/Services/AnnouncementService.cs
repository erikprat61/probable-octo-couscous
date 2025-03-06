using System;
using System.Collections.Generic;

namespace WeatherApp.Services;

/// <summary>
/// Interface for AnnouncementService
/// </summary>
public interface IAnnouncementService
{
    IEnumerable<Announcement> GetCurrentAnnouncements();
    IEnumerable<Announcement> GetAnnouncementsByPriority(AnnouncementPriority priority);
    Announcement? GetAnnouncementById(int id);
}

/// <summary>
/// Service for providing system announcements and notifications
/// </summary>
public class AnnouncementService : IAnnouncementService
{
    public IEnumerable<Announcement> GetCurrentAnnouncements()
    {
        var now = DateTime.Now;
        return _announcements.FindAll(a => a.StartDate <= now && a.EndDate >= now);
    }

    public IEnumerable<Announcement> GetAnnouncementsByPriority(AnnouncementPriority priority)
    {
        return _announcements.FindAll(a => a.Priority == priority);
    }

    public Announcement? GetAnnouncementById(int id)
    {
        return _announcements.Find(a => a.Id == id);
    }

    private static readonly List<Announcement> _announcements = new()
    {
        new Announcement
        {
            Id = 1,
            Title = "Scheduled Maintenance",
            Message = "The system will be down for scheduled maintenance on Saturday from 2 AM to 4 AM.",
            Priority = AnnouncementPriority.Important,
            StartDate = DateTime.Now.AddDays(-2),
            EndDate = DateTime.Now.AddDays(3)
        },
        new Announcement
        {
            Id = 2,
            Title = "New Feature: Weather Alerts",
            Message = "You can now subscribe to receive alerts for extreme weather conditions in your area.",
            Priority = AnnouncementPriority.Informational,
            StartDate = DateTime.Now.AddDays(-5),
            EndDate = DateTime.Now.AddDays(10)
        },
        new Announcement
        {
            Id = 3,
            Title = "API Rate Limit Change",
            Message = "Starting next month, the API rate limits will be increased for all subscription tiers.",
            Priority = AnnouncementPriority.Low,
            StartDate = DateTime.Now.AddDays(-1),
            EndDate = DateTime.Now.AddDays(14)
        },
        new Announcement
        {
            Id = 4,
            Title = "Emergency: Service Disruption",
            Message = "We are currently experiencing issues with data providers. Some weather information may be delayed.",
            Priority = AnnouncementPriority.Critical,
            StartDate = DateTime.Now.AddHours(-6),
            EndDate = DateTime.Now.AddHours(12)
        }
    };
}

/// <summary>
/// Represents a system announcement or notification
/// </summary>
public class Announcement
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public AnnouncementPriority Priority { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
}

/// <summary>
/// Priority level for announcements
/// </summary>
public enum AnnouncementPriority
{
    Low,
    Informational,
    Important,
    Critical
}