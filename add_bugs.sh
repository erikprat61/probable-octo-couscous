#!/bin/bash

# Script: add_bugs.sh
# Description: Adds controllers with one specific async bug and one LINQ bug to the WeatherApp project
# Usage: ./add_bugs.sh (after running build.sh to set up the initial project)

# Exit on error
set -e

echo "Adding simplified bug controllers and tests to the WeatherApp project..."

# Ensure we're in the right directory
if [ ! -d "WeatherApp" ]; then
    echo "Error: WeatherApp directory not found. Run this script from the root of the project."
    exit 1
fi

# Create AsyncBugController with a single clear bug
cat > WeatherApp/Controllers/AsyncBugController.cs << 'EOF'
using Microsoft.AspNetCore.Mvc;

namespace WeatherApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AsyncBugController : ControllerBase
{
    // BUG: Missing await - This bug returns immediately without waiting for the async operation
    [HttpGet]
    public async Task<IActionResult> Get()
    {
        // The bug: We don't await the DelayedOperation, so it returns immediately
        // before the operation completes
        var task = DelayedOperation();
        // Correct code would be: await task;
        
        return Ok(new { Status = "Completed", Message = "The operation should have taken 2 seconds" });
    }
    
    private async Task<string> DelayedOperation()
    {
        // This simulates a time-consuming operation (like a database query)
        await Task.Delay(2000);
        return "Operation completed";
    }
}
EOF

# Create LinqBugController with a single clear bug
cat > WeatherApp/Controllers/LinqBugController.cs << 'EOF'
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
EOF

# Create test file for AsyncBugController with timeout
cat > WeatherApp.Tests/AsyncBugControllerTests.cs << 'EOF'
using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace WeatherApp.Tests;

public class AsyncBugControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public AsyncBugControllerTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact(Timeout = 10000)] // 10 second timeout for the test
    public async Task AsyncOperation_ShouldTakeTwoSeconds()
    {
        // Arrange
        var client = _factory.CreateClient();
        client.Timeout = TimeSpan.FromSeconds(5); // Ensure we don't timeout at the HTTP level
        
        // Act
        var startTime = DateTime.UtcNow;
        var response = await client.GetAsync("/api/asyncbug");
        var endTime = DateTime.UtcNow;
        var elapsedMs = (endTime - startTime).TotalMilliseconds;
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        // This test fails because the controller doesn't await the operation
        // It should take at least 2 seconds (2000ms) to complete
        Assert.True(elapsedMs >= 1900, 
            $"Operation completed too quickly: {elapsedMs}ms. The operation should take at least 2 seconds.");
    }
}
EOF

# Create test file for LinqBugController
cat > WeatherApp.Tests/LinqBugControllerTests.cs << 'EOF'
using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace WeatherApp.Tests;

public class LinqBugControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public LinqBugControllerTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task ExtremeDaysCount_ShouldBeGreaterThanZero()
    {
        // Arrange
        var client = _factory.CreateClient();
        
        // Act
        var response = await client.GetAsync("/api/linqbug");
        var content = await response.Content.ReadAsStringAsync();
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        // Parse the response
        var result = JsonSerializer.Deserialize<JsonElement>(content);
        var extremeDaysCount = result.GetProperty("extremeDaysCount").GetInt32();
        
        // This test fails because the LINQ query has a logical error
        // With 100 days of random weather data, some days should be extreme
        // But the query is checking for impossible conditions
        Assert.True(extremeDaysCount > 0, 
            "No extreme weather days found. This is unexpected with 100 days of data. " +
            "Check the LINQ query logic - no day can be both below -15°C AND above 40°C simultaneously.");
    }
}
EOF

echo "Building and running tests to verify the bugs are properly implemented..."
dotnet build
dotnet test

echo "Bug implementations complete. The tests are designed to fail until the bugs are fixed."
echo ""
echo "To reset the project: rm -rf WeatherApp WeatherApp.Tests .vscode .devcontainer *.sln global.json .gitignore"
echo "Then run: ./build.sh && ./add_bugs.sh"