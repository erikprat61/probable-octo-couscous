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
