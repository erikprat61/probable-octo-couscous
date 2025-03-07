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
