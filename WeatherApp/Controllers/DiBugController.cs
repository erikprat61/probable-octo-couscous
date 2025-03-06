using Microsoft.AspNetCore.Mvc;
using WeatherApp.Services;

namespace WeatherApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DIBugController : ControllerBase
{
    private readonly IWeatherService _weatherService;
    private readonly IAnnouncementService _announcementService;

    public DIBugController(
        IWeatherService weatherService,
        IAnnouncementService announcementService)
    {
        _announcementService = announcementService;
        _weatherService = weatherService;
    }

    [HttpGet]
    public IActionResult Get()
    {
        var announcements = _announcementService.GetCurrentAnnouncements();
        return Ok(announcements);
    }

    [HttpGet("featured")]
    public IActionResult GetFeatured()
    {
        var forecasts = _weatherService.GetFeaturedForecasts();

        return Ok(forecasts);
    }
}