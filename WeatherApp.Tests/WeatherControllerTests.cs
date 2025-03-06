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
        Assert.True(forecast.TryGetProperty("temperatureF", out _));
        Assert.True(forecast.TryGetProperty("summary", out var summary));
        
        // Check some basic values
        Assert.Equal(20, tempC.GetInt32());
        Assert.Equal("Sunny", summary.GetString());
    }
}
