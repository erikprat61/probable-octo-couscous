using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace WeatherApp.Tests;

public class WeatherControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public WeatherControllerTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Get_ReturnsWeatherForecast()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/api/weather");
        var content = await response.Content.ReadAsStringAsync();
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        // Verify it contains the expected properties
        var forecast = JsonSerializer.Deserialize<JsonElement>(content);
        Assert.True(forecast.TryGetProperty("date", out _));
        Assert.True(forecast.TryGetProperty("temperatureC", out var tempC));
        Assert.True(forecast.TryGetProperty("temperatureF", out var tempF));
        Assert.True(forecast.TryGetProperty("summary", out var summary));
        
        // Check some basic values
        Assert.Equal(20, tempC.GetInt32());
        // 20°C should be approximately 68°F (the correct conversion is 68°F)
        Assert.Equal(68, tempF.GetInt32());
        Assert.Equal("Sunny", summary.GetString());
    }
    
    [Fact]
    public async Task GetWeekForecast_ReturnsMultipleForecasts()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/api/weather/week");
        var content = await response.Content.ReadAsStringAsync();
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        // Verify we get an array of forecasts
        var forecasts = JsonSerializer.Deserialize<JsonElement>(content);
        Assert.Equal(JsonValueKind.Array, forecasts.ValueKind);
        Assert.Equal(4, forecasts.GetArrayLength());
        
        // Check the first item has all required properties
        var firstItem = forecasts[0];
        Assert.True(firstItem.TryGetProperty("date", out _));
        Assert.True(firstItem.TryGetProperty("temperatureC", out _));
        Assert.True(firstItem.TryGetProperty("temperatureF", out _));
        Assert.True(firstItem.TryGetProperty("summary", out _));
    }
}
