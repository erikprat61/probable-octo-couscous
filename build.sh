#!/bin/bash

# Exit on error
set -e

echo "Creating .NET 9 API project structure..."

# Create solution and projects
mkdir -p WeatherApp/Controllers
mkdir -p WeatherApp/Models
mkdir -p WeatherApp/Services
mkdir -p WeatherApp/Repositories
mkdir -p WeatherApp.Tests
mkdir -p .vscode
mkdir -p .devcontainer

# Create solution file
cat > WeatherApp.sln << 'EOF'
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "WeatherApp", "WeatherApp\WeatherApp.csproj", "{16A9FC7F-0CB3-4A09-9879-DD63F1D82D2D}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "WeatherApp.Tests", "WeatherApp.Tests\WeatherApp.Tests.csproj", "{63D83A2D-B2B5-48F3-8A3C-5B8869DCFF7A}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{16A9FC7F-0CB3-4A09-9879-DD63F1D82D2D}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{16A9FC7F-0CB3-4A09-9879-DD63F1D82D2D}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{16A9FC7F-0CB3-4A09-9879-DD63F1D82D2D}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{16A9FC7F-0CB3-4A09-9879-DD63F1D82D2D}.Release|Any CPU.Build.0 = Release|Any CPU
		{63D83A2D-B2B5-48F3-8A3C-5B8869DCFF7A}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{63D83A2D-B2B5-48F3-8A3C-5B8869DCFF7A}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{63D83A2D-B2B5-48F3-8A3C-5B8869DCFF7A}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{63D83A2D-B2B5-48F3-8A3C-5B8869DCFF7A}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
EndGlobal
EOF

# Create API project files
cat > WeatherApp/WeatherApp.csproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <InvariantGlobalization>true</InvariantGlobalization>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
  </ItemGroup>

</Project>
EOF

# Create Models
cat > WeatherApp/Models/WeatherForecast.cs << 'EOF'
namespace WeatherApp.Models;

public class WeatherForecast
{
    public int Id { get; set; }
    public DateOnly Date { get; set; }
    public int TemperatureC { get; set; }
    public string? Summary { get; set; }
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
EOF

cat > WeatherApp/Models/WeatherSummary.cs << 'EOF'
namespace WeatherApp.Models;

public class WeatherSummary
{
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public double AverageTemperatureC { get; set; }
    public double AverageTemperatureF => 32 + (AverageTemperatureC / 0.5556);
    public string? OverallSummary { get; set; }
}
EOF

# Create Service Interfaces
cat > WeatherApp/Services/ITimeService.cs << 'EOF'
namespace WeatherApp.Services;

public interface ITimeService
{
    DateTime GetCurrentTime();
    string GetTimeStamp();
}
EOF

cat > WeatherApp/Services/IWeatherService.cs << 'EOF'
using WeatherApp.Models;

namespace WeatherApp.Services;

public interface IWeatherService
{
    Task<IEnumerable<WeatherForecast>> GetForecastsAsync(int days);
    Task<WeatherForecast?> GetForecastByIdAsync(int id);
    Task<WeatherSummary> GetWeatherSummaryAsync(DateOnly startDate, DateOnly endDate);
}
EOF

# Create Service Implementations
cat > WeatherApp/Services/TimeService.cs << 'EOF'
namespace WeatherApp.Services;

// This service demonstrates the DI lifetime scope issues
public class TimeService : ITimeService
{
    private readonly DateTime _creationTime;

    public TimeService()
    {
        _creationTime = DateTime.UtcNow;
    }

    public DateTime GetCurrentTime() => DateTime.UtcNow;

    public string GetTimeStamp() => _creationTime.ToString("o");
}
EOF

cat > WeatherApp/Services/WeatherService.cs << 'EOF'
using WeatherApp.Models;
using WeatherApp.Repositories;

namespace WeatherApp.Services;

public class WeatherService : IWeatherService
{
    private readonly IWeatherRepository _weatherRepository;
    private readonly ITimeService _timeService;

    public WeatherService(IWeatherRepository weatherRepository, ITimeService timeService)
    {
        _weatherRepository = weatherRepository;
        _timeService = timeService;
    }

    public async Task<IEnumerable<WeatherForecast>> GetForecastsAsync(int days)
    {
        // Log access time
        Console.WriteLine($"Weather data accessed at: {_timeService.GetTimeStamp()}");
        return await _weatherRepository.GetForecastsAsync(days);
    }

    public async Task<WeatherForecast?> GetForecastByIdAsync(int id)
    {
        return await _weatherRepository.GetForecastByIdAsync(id);
    }

    public async Task<WeatherSummary> GetWeatherSummaryAsync(DateOnly startDate, DateOnly endDate)
    {
        var forecasts = await _weatherRepository.GetForecastsInRangeAsync(startDate, endDate);
        
        return new WeatherSummary
        {
            StartDate = startDate,
            EndDate = endDate,
            AverageTemperatureC = forecasts.Average(f => f.TemperatureC),
            OverallSummary = GetMostCommonSummary(forecasts)
        };
    }

    private string? GetMostCommonSummary(IEnumerable<WeatherForecast> forecasts)
    {
        return forecasts
            .GroupBy(f => f.Summary)
            .OrderByDescending(g => g.Count())
            .Select(g => g.Key)
            .FirstOrDefault();
    }
}
EOF

# Create Repository Interface
cat > WeatherApp/Repositories/IWeatherRepository.cs << 'EOF'
using WeatherApp.Models;

namespace WeatherApp.Repositories;

public interface IWeatherRepository
{
    Task<IEnumerable<WeatherForecast>> GetForecastsAsync(int count);
    Task<WeatherForecast?> GetForecastByIdAsync(int id);
    Task<IEnumerable<WeatherForecast>> GetForecastsInRangeAsync(DateOnly startDate, DateOnly endDate);
}
EOF

# Create Repository Implementation
cat > WeatherApp/Repositories/WeatherRepository.cs << 'EOF'
using WeatherApp.Models;

namespace WeatherApp.Repositories;

public class WeatherRepository : IWeatherRepository
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly List<WeatherForecast> _forecasts;

    public WeatherRepository()
    {
        // Initialize with some sample data
        var random = new Random();
        _forecasts = Enumerable.Range(1, 100).Select(index => new WeatherForecast
        {
            Id = index,
            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            TemperatureC = random.Next(-20, 55),
            Summary = Summaries[random.Next(Summaries.Length)]
        }).ToList();
    }

    public async Task<IEnumerable<WeatherForecast>> GetForecastsAsync(int count)
    {
        // Simulate async operation
        await Task.Delay(10);
        return _forecasts.Take(count);
    }

    public async Task<WeatherForecast?> GetForecastByIdAsync(int id)
    {
        // Simulate async operation
        await Task.Delay(10);
        return _forecasts.FirstOrDefault(f => f.Id == id);
    }

    public async Task<IEnumerable<WeatherForecast>> GetForecastsInRangeAsync(DateOnly startDate, DateOnly endDate)
    {
        // Simulate async operation
        await Task.Delay(10);
        return _forecasts.Where(f => f.Date >= startDate && f.Date <= endDate);
    }
}
EOF

# Create Program.cs with DI setup
cat > WeatherApp/Program.cs << 'EOF'
using WeatherApp.Repositories;
using WeatherApp.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register services
builder.Services.AddSingleton<ITimeService, TimeService>();
builder.Services.AddScoped<IWeatherService, WeatherService>();
builder.Services.AddSingleton<IWeatherRepository, WeatherRepository>();

// Configure Kestrel for Codespaces environment to prevent HTTPS errors
if (Environment.GetEnvironmentVariable("CODESPACES")?.Equals("true", StringComparison.OrdinalIgnoreCase) == true)
{
    builder.WebHost.ConfigureKestrel(options =>
    {
        options.ListenAnyIP(5000); // HTTP only
    });
}

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    
    // Add a redirect from the root URL to Swagger, but hide it from Swagger docs
    app.MapGet("/", () => Results.Redirect("/swagger"))
       .ExcludeFromDescription();
}

// Only use HTTPS redirection when not in Codespaces
if (Environment.GetEnvironmentVariable("CODESPACES")?.Equals("true", StringComparison.OrdinalIgnoreCase) != true)
{
    app.UseHttpsRedirection();
}

app.UseAuthorization();
app.MapControllers();

app.Run();

// Make the Program class public for testing
public partial class Program { }
EOF

# Create Updated WeatherController
cat > WeatherApp/Controllers/WeatherController.cs << 'EOF'
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
EOF

# Create test project files
cat > WeatherApp.Tests/WeatherApp.Tests.csproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="9.0.0" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.9.0" />
    <PackageReference Include="Moq" Version="4.20.70" />
    <PackageReference Include="xunit" Version="2.6.1" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.3">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\WeatherApp\WeatherApp.csproj" />
  </ItemGroup>

</Project>
EOF

# Create Integration Tests
cat > WeatherApp.Tests/WeatherControllerIntegrationTests.cs << 'EOF'
using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using WeatherApp.Models;
using Xunit;

namespace WeatherApp.Tests;

public class WeatherControllerIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public WeatherControllerIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Get_ReturnsForecasts()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/api/weather");
        var content = await response.Content.ReadAsStringAsync();
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var forecasts = JsonSerializer.Deserialize<List<WeatherForecast>>(content, options);
        
        Assert.NotNull(forecasts);
        Assert.Equal(5, forecasts.Count); // Default is 5 days
    }

    [Fact]
    public async Task GetById_ReturnsCorrectForecast()
    {
        // Arrange
        var client = _factory.CreateClient();
        var id = 1;

        // Act
        var response = await client.GetAsync($"/api/weather/{id}");
        var content = await response.Content.ReadAsStringAsync();
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var forecast = JsonSerializer.Deserialize<WeatherForecast>(content, options);
        
        Assert.NotNull(forecast);
        Assert.Equal(id, forecast.Id);
    }

    [Fact]
    public async Task GetSummary_ReturnsCorrectSummary()
    {
        // Arrange
        var client = _factory.CreateClient();
        var start = DateTime.Now.Date;  // Use start of day
        var end = start.AddDays(5);     // End is definitely after start

        // Act
        var response = await client.GetAsync($"/api/weather/summary?start={start:o}&end={end:o}");
        var content = await response.Content.ReadAsStringAsync();
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var summary = JsonSerializer.Deserialize<WeatherSummary>(content, options);
        
        Assert.NotNull(summary);
        Assert.Equal(DateOnly.FromDateTime(start), summary.StartDate);
        Assert.Equal(DateOnly.FromDateTime(end), summary.EndDate);
    }

    [Fact]
    public async Task GetTime_ReturnsTimeInformation()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/api/weather/time");
        var content = await response.Content.ReadAsStringAsync();
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var result = JsonDocument.Parse(content);
        
        Assert.True(result.RootElement.TryGetProperty("currentTime", out _));
        Assert.True(result.RootElement.TryGetProperty("timeStamp", out _));
    }
}
EOF

# Create Unit Tests
cat > WeatherApp.Tests/WeatherControllerTests.cs << 'EOF'
using Microsoft.AspNetCore.Mvc;
using Moq;
using WeatherApp.Controllers;
using WeatherApp.Models;
using WeatherApp.Services;
using Xunit;

namespace WeatherApp.Tests;

public class WeatherControllerTests
{
    private readonly Mock<IWeatherService> _mockWeatherService;
    private readonly Mock<ITimeService> _mockTimeService;
    private readonly WeatherController _controller;

    public WeatherControllerTests()
    {
        _mockWeatherService = new Mock<IWeatherService>();
        _mockTimeService = new Mock<ITimeService>();
        _controller = new WeatherController(_mockWeatherService.Object, _mockTimeService.Object);
    }

    [Fact]
    public async Task Get_ReturnsOk_WithForecasts()
    {
        // Arrange
        var days = 3;
        var forecasts = new List<WeatherForecast>
        {
            new() { Id = 1, Date = DateOnly.FromDateTime(DateTime.Now), TemperatureC = 20, Summary = "Sunny" },
            new() { Id = 2, Date = DateOnly.FromDateTime(DateTime.Now.AddDays(1)), TemperatureC = 25, Summary = "Warm" },
            new() { Id = 3, Date = DateOnly.FromDateTime(DateTime.Now.AddDays(2)), TemperatureC = 15, Summary = "Cool" }
        };
        
        _mockWeatherService
            .Setup(s => s.GetForecastsAsync(days))
            .ReturnsAsync(forecasts);
            
        // Act
        var result = await _controller.Get(days);
            
        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var returnedForecasts = Assert.IsAssignableFrom<IEnumerable<WeatherForecast>>(okResult.Value);
        Assert.Equal(3, returnedForecasts.Count());
        _mockWeatherService.Verify(s => s.GetForecastsAsync(days), Times.Once);
    }

    [Fact]
    public async Task GetById_ReturnsOk_WhenForecastExists()
    {
        // Arrange
        var id = 1;
        var forecast = new WeatherForecast { Id = id, Date = DateOnly.FromDateTime(DateTime.Now), TemperatureC = 20, Summary = "Sunny" };
        
        _mockWeatherService
            .Setup(s => s.GetForecastByIdAsync(id))
            .ReturnsAsync(forecast);
            
        // Act
        var result = await _controller.GetById(id);
            
        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var returnedForecast = Assert.IsType<WeatherForecast>(okResult.Value);
        Assert.Equal(id, returnedForecast.Id);
        _mockWeatherService.Verify(s => s.GetForecastByIdAsync(id), Times.Once);
    }

    [Fact]
    public async Task GetById_ReturnsNotFound_WhenForecastDoesNotExist()
    {
        // Arrange
        var id = 999;
        
        _mockWeatherService
            .Setup(s => s.GetForecastByIdAsync(id))
            .ReturnsAsync((WeatherForecast?)null);
            
        // Act
        var result = await _controller.GetById(id);
            
        // Assert
        Assert.IsType<NotFoundResult>(result);
        _mockWeatherService.Verify(s => s.GetForecastByIdAsync(id), Times.Once);
    }

    [Fact]
    public async Task GetSummary_ReturnsOk_WithSummary()
    {
        // Arrange
        var start = DateTime.Now;
        var end = start.AddDays(5);
        var startDate = DateOnly.FromDateTime(start);
        var endDate = DateOnly.FromDateTime(end);
        
        var summary = new WeatherSummary
        {
            StartDate = startDate,
            EndDate = endDate,
            AverageTemperatureC = 22.5,
            OverallSummary = "Sunny"
        };
        
        _mockWeatherService
            .Setup(s => s.GetWeatherSummaryAsync(startDate, endDate))
            .ReturnsAsync(summary);
            
        // Act
        var result = await _controller.GetSummary(start, end);
            
        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var returnedSummary = Assert.IsType<WeatherSummary>(okResult.Value);
        Assert.Equal(startDate, returnedSummary.StartDate);
        Assert.Equal(endDate, returnedSummary.EndDate);
        Assert.Equal(22.5, returnedSummary.AverageTemperatureC);
        _mockWeatherService.Verify(s => s.GetWeatherSummaryAsync(startDate, endDate), Times.Once);
    }

    [Fact]
    public async Task GetSummary_ReturnsBadRequest_WhenStartDateIsAfterEndDate()
    {
        // Arrange
        var start = DateTime.Now.AddDays(5);
        var end = DateTime.Now;
            
        // Act
        var result = await _controller.GetSummary(start, end);
            
        // Assert
        Assert.IsType<BadRequestObjectResult>(result);
        _mockWeatherService.Verify(s => s.GetWeatherSummaryAsync(It.IsAny<DateOnly>(), It.IsAny<DateOnly>()), Times.Never);
    }

    [Fact]
    public void GetTime_ReturnsOk_WithTimeInformation()
    {
        // Arrange
        var currentTime = DateTime.Now;
        var timeStamp = "2025-03-05T12:34:56.7890Z";
        
        _mockTimeService
            .Setup(s => s.GetCurrentTime())
            .Returns(currentTime);
            
        _mockTimeService
            .Setup(s => s.GetTimeStamp())
            .Returns(timeStamp);
            
        // Act
        var result = _controller.GetTime();
            
        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var resultDict = Assert.IsType<Dictionary<string, object>>(okResult.Value);
        
        Assert.True(resultDict.ContainsKey("currentTime"));
        Assert.True(resultDict.ContainsKey("timeStamp"));
        Assert.Equal(currentTime, resultDict["currentTime"]);
        Assert.Equal(timeStamp, resultDict["timeStamp"]);
        
        _mockTimeService.Verify(s => s.GetCurrentTime(), Times.Once);
        _mockTimeService.Verify(s => s.GetTimeStamp(), Times.Once);
    }
}
EOF

# Create TimeService Test to verify DI lifetime scopes
cat > WeatherApp.Tests/TimeServiceTests.cs << 'EOF'
using Microsoft.AspNetCore.Mvc.Testing;
using System.Text.Json;
using Xunit;

namespace WeatherApp.Tests;

public class TimeServiceTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public TimeServiceTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Singleton_TimeService_MaintainsConsistentTimeStamp()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response1 = await client.GetAsync("/api/weather/time");
        var content1 = await response1.Content.ReadAsStringAsync();
        
        // Wait a bit to ensure time would change if not singleton
        await Task.Delay(100);
        
        var response2 = await client.GetAsync("/api/weather/time");
        var content2 = await response2.Content.ReadAsStringAsync();
        
        // Assert
        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var time1 = JsonDocument.Parse(content1);
        var time2 = JsonDocument.Parse(content2);
        
        time1.RootElement.TryGetProperty("timeStamp", out var timeStamp1);
        time2.RootElement.TryGetProperty("timeStamp", out var timeStamp2);
        
        // TimeStamp should be the same for both requests if it's a singleton
        Assert.Equal(timeStamp1.GetString(), timeStamp2.GetString());
    }
}
EOF

# Create Weather Service Tests to verify LINQ and async operations
cat > WeatherApp.Tests/WeatherServiceTests.cs << 'EOF'
using Moq;
using WeatherApp.Models;
using WeatherApp.Repositories;
using WeatherApp.Services;
using Xunit;

namespace WeatherApp.Tests;

public class WeatherServiceTests
{
    private readonly Mock<IWeatherRepository> _mockRepository;
    private readonly Mock<ITimeService> _mockTimeService;
    private readonly WeatherService _weatherService;

    public WeatherServiceTests()
    {
        _mockRepository = new Mock<IWeatherRepository>();
        _mockTimeService = new Mock<ITimeService>();
        _weatherService = new WeatherService(_mockRepository.Object, _mockTimeService.Object);
    }

    [Fact]
    public async Task GetForecastsAsync_ReturnsForecasts()
    {
        // Arrange
        var days = 3;
        var forecasts = new List<WeatherForecast>
        {
            new() { Id = 1, Date = DateOnly.FromDateTime(DateTime.Now), TemperatureC = 20, Summary = "Sunny" },
            new() { Id = 2, Date = DateOnly.FromDateTime(DateTime.Now.AddDays(1)), TemperatureC = 25, Summary = "Warm" },
            new() { Id = 3, Date = DateOnly.FromDateTime(DateTime.Now.AddDays(2)), TemperatureC = 15, Summary = "Cool" }
        };
        
        _mockRepository
            .Setup(r => r.GetForecastsAsync(days))
            .ReturnsAsync(forecasts);
            
        _mockTimeService
            .Setup(t => t.GetTimeStamp())
            .Returns("2025-03-05T12:34:56.7890Z");
            
        // Act
        var result = await _weatherService.GetForecastsAsync(days);
            
        // Assert
        Assert.Equal(forecasts, result);
        _mockRepository.Verify(r => r.GetForecastsAsync(days), Times.Once);
        _mockTimeService.Verify(t => t.GetTimeStamp(), Times.Once);
    }

    [Fact]
    public async Task GetWeatherSummaryAsync_CalculatesCorrectAverages()
    {
        // Arrange
        var startDate = DateOnly.FromDateTime(DateTime.Now);
        var endDate = startDate.AddDays(2);
        
        var forecasts = new List<WeatherForecast>
        {
            new() { Id = 1, Date = startDate, TemperatureC = 20, Summary = "Sunny" },
            new() { Id = 2, Date = startDate.AddDays(1), TemperatureC = 25, Summary = "Sunny" },
            new() { Id = 3, Date = endDate, TemperatureC = 15, Summary = "Cool" }
        };
        
        _mockRepository
            .Setup(r => r.GetForecastsInRangeAsync(startDate, endDate))
            .ReturnsAsync(forecasts);
            
        // Act
        var result = await _weatherService.GetWeatherSummaryAsync(startDate, endDate);
            
        // Assert
        Assert.Equal(startDate, result.StartDate);
        Assert.Equal(endDate, result.EndDate);
        Assert.Equal(20, result.AverageTemperatureC); // (20 + 25 + 15) / 3 = 20
        Assert.Equal("Sunny", result.OverallSummary); // 2 Sunny vs 1 Cool
        _mockRepository.Verify(r => r.GetForecastsInRangeAsync(startDate, endDate), Times.Once);
    }
}
EOF

# Create .devcontainer configuration
cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "C# (.NET)",
  "image": "mcr.microsoft.com/devcontainers/dotnet:latest",
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": {
      "version": "9.0"
    }
  },
  "forwardPorts": [5000],
  "postCreateCommand": "chmod +x build.sh && ./build.sh",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-dotnettools.csharp",
        "ms-dotnettools.vscode-dotnet-runtime",
        "formulahendry.dotnet-test-explorer"
      ],
      "settings": {
        "omnisharp.enableRoslynAnalyzers": true,
        "omnisharp.enableEditorConfigSupport": true,
        "dotnet-test-explorer.testProjectPath": "**/*.Tests.csproj"
      }
    }
  }
}
EOF

# Create .vscode configuration
cat > .vscode/launch.json << 'EOF'
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": ".NET Launch (web)",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build",
      "program": "${workspaceFolder}/WeatherApp/bin/Debug/net9.0/WeatherApp.dll",
      "args": [],
      "cwd": "${workspaceFolder}/WeatherApp",
      "stopAtEntry": false,
      "serverReadyAction": {
        "action": "openExternally",
        "pattern": "\\bNow listening on:\\s+(https?://\\S+)",
        "uriFormat": "%s/swagger"
      },
      "env": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "ASPNETCORE_URLS": "http://localhost:5000",
        "CODESPACES": "true"
      },
      "sourceFileMap": {
        "/Views": "${workspaceFolder}/Views"
      }
    }
  ]
}
EOF

cat > .vscode/tasks.json << 'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "build",
      "command": "dotnet",
      "type": "process",
      "args": [
        "build",
        "${workspaceFolder}/WeatherApp.sln",
        "/property:GenerateFullPaths=true",
        "/consoleloggerparameters:NoSummary"
      ],
      "problemMatcher": "$msCompile"
    },
    {
      "label": "test",
      "command": "dotnet",
      "type": "process",
      "args": [
        "test",
        "${workspaceFolder}/WeatherApp.Tests/WeatherApp.Tests.csproj",
        "/property:GenerateFullPaths=true",
        "/consoleloggerparameters:NoSummary"
      ],
      "problemMatcher": "$msCompile",
      "group": {
        "kind": "test",
        "isDefault": true
      }
    }
  ]
}
EOF

# Add global.json to ensure .NET 9 usage
cat > global.json << 'EOF'
{
  "sdk": {
    "version": "9.0.100",
    "rollForward": "latestMajor"
  }
}
EOF

# Create .gitignore file for .NET projects
cat > .gitignore << 'EOF'
# Visual Studio / .NET specific
[Oo]bj/
[Bb]in/
.vs/
_UpgradeReport_Files/
[Pp]ackages/
*.user
*.suo
*.userprefs
*.usertasks
*.userosscache
*.sln.docstates
*.vspscc
*.vssscc
.builds
*.pidb
*.svclog
*.log
*_i.c
*_p.c
*.ilk
*.meta
*.obj
*.pch
*.pdb
*.pgc
*.pgd
*.rsp
*.sbr
*.tlb
*.tli
*.tlh
*.tmp
*.tmp_proj
*.vsidx
*_wpftmp.csproj
*.sqlite
*.sdf
*.opensdf
*.cachefile
*.VC.db
*.VC.VC.opendb
FakesAssemblies/

# .NET Core
project.lock.json
project.fragment.lock.json
artifacts/
**/Properties/launchSettings.json

# User-specific files
*.rsuser
*.suo
*.user
*.userosscache
*.sln.docstates

# Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
[Rr]eleases/
x64/
x86/
[Ww][Ii][Nn]32/
[Aa][Rr][Mm]/
[Aa][Rr][Mm]64/
bld/
[Bb]in/
[Oo]bj/
[Ll]og/
[Ll]ogs/

# NuGet Packages
*.nupkg
*.snupkg
**/[Pp]ackages/*
!**/[Pp]ackages/build/
*.nuget.props
*.nuget.targets

# JetBrains Rider
.idea/
*.sln.iml

# Visual Studio Code - explicitly include configuration files
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
*.code-workspace

# macOS
.DS_Store

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/
EOF

# Add README with bug pattern information
cat > README.md << 'EOF'
# Weather App Bug Hunt Interview Project

This project is designed as a template for creating programming interview exercises that test a candidate's ability to find and fix bugs related to:

1. Dependency Injection and Lifetime Scopes
2. LINQ Queries
3. Async Operations

## How to Use This Template

To create a bug-hunting exercise for candidates:

1. Modify `Program.cs` to introduce dependency injection bugs (e.g., change service lifetimes)
2. Modify `WeatherService.cs` to introduce LINQ query bugs
3. Modify `WeatherController.cs` to introduce async/await issues
4. Run the tests to verify they fail when the bugs are present

The failing tests will indicate to candidates what needs to be fixed.

## Common Bug Patterns to Introduce

### Dependency Injection Lifetime Bugs

- Register a service as Transient but use it in a Singleton context
- Register a scoped service with a singleton dependency
- Register ITimeService as Transient (instead of Singleton) to break the TimeServiceTests

### LINQ Query Bugs

- Add `.ToList()` or `.ToArray()` in the middle of a LINQ chain incorrectly
- Use GroupBy without proper ordering in the GetMostCommonSummary method
- Use FirstOrDefault without proper null checking
- Swap OrderBy and OrderByDescending to get wrong results

### Async Bugs

- Remove await keywords in controller methods
- Use Result or Wait() instead of await
- Return Task.FromResult() in blocking code
- Forget to use ConfigureAwait(false) in a library context

## Running the Project

- Use `dotnet build` to build the solution
- Use `dotnet test` to run the tests
- Use F5 in VS Code to run and debug the application

## Tests Included

- Unit tests for WeatherController
- Integration tests with WebApplicationFactory
- Service tests for WeatherService
- TimeService tests to verify DI behavior
EOF

# Ensure .NET 9 is installed and active
echo "Checking .NET version..."
dotnet --info

echo "Building the solution..."
dotnet restore
dotnet build 
# Only run tests after build succeeds
if [ $? -eq 0 ]; then
  dotnet test
fi

echo "Setup complete! You can now launch the API using F5 or run tests with the 'Run Tests' button."