using Microsoft.AspNetCore.Mvc;

namespace WeatherApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AsyncBugController : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var task = DelayedOperation();
        
        return Ok(new { Status = "Completed", Message = "The operation should have taken 2 seconds" });
    }
    
    private async Task<string> DelayedOperation()
    {
        // This simulates a time-consuming operation (like a database query)
        await Task.Delay(2000);
        return "Operation completed";
    }
}
