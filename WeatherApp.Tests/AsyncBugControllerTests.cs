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

    [Fact(Timeout = 10000)]
    public async Task AsyncOperation_ShouldTakeTwoSeconds()
    {
        // Arrange
        var client = _factory.CreateClient();
        client.Timeout = TimeSpan.FromSeconds(5); // Ensure we don't timeout
        
        // Act
        var startTime = DateTime.UtcNow;
        var response = await client.GetAsync("/api/asyncbug");
        var endTime = DateTime.UtcNow;
        var elapsedMs = (endTime - startTime).TotalMilliseconds;
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        Assert.True(elapsedMs >= 1900, 
            $"Operation completed too quickly: {elapsedMs}ms. The operation should take at least 2 seconds.");
    }
}
