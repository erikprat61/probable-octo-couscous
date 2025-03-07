using Microsoft.AspNetCore.Mvc;
using WeatherApp.Models;
using WeatherApp.Services;

namespace WeatherApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WeatherController : ControllerBase
{
    private readonly IWeatherService _weatherService;
    private readonly ITimeService _timeService;

    public WeatherController(IWeatherService weatherService, ITimeService timeService)
    {
        _weatherService = weatherService;
        _timeService = timeService;
    }

    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] int days = 5)
    {
        var result = await _weatherService.GetForecastsAsync(days);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var forecast = await _weatherService.GetForecastByIdAsync(id);
        
        if (forecast == null)
        {
            return NotFound();
        }
        
        return Ok(forecast);
    }

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary([FromQuery] DateTime start, [FromQuery] DateTime end)
    {
        var startDate = DateOnly.FromDateTime(start);
        var endDate = DateOnly.FromDateTime(end);
        
        if (startDate > endDate)
        {
            return BadRequest("Start date must be before end date");
        }
        
        var summary = await _weatherService.GetWeatherSummaryAsync(startDate, endDate);
        return Ok(summary);
    }

    [HttpGet("time")]
    public IActionResult GetTime()
    {
        return Ok(new Dictionary<string, object>
        { 
            ["currentTime"] = _timeService.GetCurrentTime(),
            ["timeStamp"] = _timeService.GetTimeStamp()
        });
    }
}
