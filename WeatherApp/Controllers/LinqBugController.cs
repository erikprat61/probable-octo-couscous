using System.Linq;
using Microsoft.AspNetCore.Mvc;
using WeatherApp.Models;

namespace WeatherApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LinqBugController : ControllerBase
{
    private static readonly List<WeatherForecast> _forecasts;
    
    static LinqBugController()
    {
        // Generate test data
        var rng = new Random(123); // Fixed seed for consistency
        var summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };
        
        _forecasts = Enumerable.Range(1, 100).Select(index => new WeatherForecast
        {
            Date = DateTime.Now.AddDays(index),
            TemperatureC = rng.Next(-20, 55),
            Summary = summaries[rng.Next(summaries.Length)]
        }).ToList();
    }
    
    // BUG: Incorrect predicate logic - the conditions make no logical sense
    [HttpGet]
    public IActionResult Get()
    {
        // The bug: This condition is logically impossible because no single day
        // can be both below -15°C AND above 40°C simultaneously
        var extremeDays = _forecasts.Where(f => 
            f.TemperatureC < -15 &&  // Should be OR (||) not AND (&&)
            f.TemperatureC > 40
        ).ToList();
        
        // Returns count of extreme days (will always be 0 with the bug)
        return Ok(new { 
            TotalDays = _forecasts.Count,
            ExtremeDaysCount = extremeDays.Count,
            ExtremeDays = extremeDays.Select(f => new { 
                Date = f.Date.ToString("yyyy-MM-dd"),
                TemperatureC = f.TemperatureC,
                Summary = f.Summary
            })
        });
    }
}
