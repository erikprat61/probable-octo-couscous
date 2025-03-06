using Microsoft.AspNetCore.Mvc;
using WeatherApp.Models;

namespace WeatherApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LinqBugController : ControllerBase
{
    // Sample weather forecast data with some forecasts marked as featured
    private static readonly List<WeatherForecast> _forecasts = new List<WeatherForecast>
    {
        new WeatherForecast { Date = DateTime.Now.AddDays(1), TemperatureC = -20, Summary = "Freezing", IsFeatured = true },
        new WeatherForecast { Date = DateTime.Now.AddDays(2), TemperatureC = -10, Summary = "Bracing", IsFeatured = false },
        new WeatherForecast { Date = DateTime.Now.AddDays(3), TemperatureC = 0, Summary = "Chilly", IsFeatured = false },
        new WeatherForecast { Date = DateTime.Now.AddDays(4), TemperatureC = 10, Summary = "Cool", IsFeatured = true },
        new WeatherForecast { Date = DateTime.Now.AddDays(5), TemperatureC = 20, Summary = "Mild", IsFeatured = false },
        new WeatherForecast { Date = DateTime.Now.AddDays(6), TemperatureC = 30, Summary = "Warm", IsFeatured = false },
        new WeatherForecast { Date = DateTime.Now.AddDays(7), TemperatureC = 40, Summary = "Hot", IsFeatured = true },
        new WeatherForecast { Date = DateTime.Now.AddDays(8), TemperatureC = 50, Summary = "Scorching", IsFeatured = false },
    };
    
    /// <summary>
    /// Retrieves featured weather forecasts that have been selected for highlighting
    /// </summary>
    /// <returns>A collection of featured weather forecasts</returns>
    [HttpGet]
    public IActionResult Get()
    {
        // Retrieve all forecasts from the data source
        var allForecasts = _forecasts.ToList();
        
        // TODO: Filter for featured forecasts only
        var featuredForecasts = allForecasts;
        
        // Return the featured forecasts with metadata
        return Ok(new { 
            TotalForecasts = _forecasts.Count,
            FeaturedCount = featuredForecasts.Count,
            FeaturedForecasts = featuredForecasts.Select(f => new { 
                Date = f.Date.ToString("yyyy-MM-dd"),
                TemperatureC = f.TemperatureC,
                Summary = f.Summary,
                IsFeatured = f.IsFeatured
            })
        });
    }
}