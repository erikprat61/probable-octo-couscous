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
