using Microsoft.AspNetCore.Mvc;

namespace WeatherApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WeatherController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        var forecast = new
        {
            Date = DateTime.Now,
            TemperatureC = 20,
            TemperatureF = 68,
            Summary = "Sunny"
        };
        
        return Ok(forecast);
    }
}
