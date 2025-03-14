using Microsoft.AspNetCore.Mvc;
using WeatherApp.Services;

namespace WeatherApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DIBugController : ControllerBase
{
    private readonly IWeatherService _weatherService;
    
    // BUG: The controller properly accepts IWeatherService but then ignores it
    public DIBugController(IWeatherService weatherService)
    {
        // We accept the injected service, but we don't use it
        _weatherService = weatherService;
    }
    
    /// <summary>
    /// Gets all weather forecasts
    /// </summary>
    [HttpGet]
    public IActionResult Get()
    {
        try
        {
            // BUG: Instead of using the injected service, 
            // we're trying to use AnnouncementService, which is a completely different service
            //var announcementService = new AnnouncementService();
            var announcementService = new AnnouncementService();
            
            // This is a type error - we're trying to treat announcements as weather forecasts
            var announcements = announcementService.GetCurrentAnnouncements();
            
            // Will fail at runtime because we're returning the wrong type
            return Ok(announcements);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = ex.Message });
        }
    }
    
    /// <summary>
    /// Gets featured weather forecasts
    /// This endpoint uses the correctly injected service
    /// </summary>
    [HttpGet("featured")]
    public IActionResult GetFeatured()
    {
        try
        {
            // Correctly using the injected service
            var forecasts = _weatherService.GetFeaturedForecasts();
            return Ok(forecasts);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = ex.Message });
        }
    }
}