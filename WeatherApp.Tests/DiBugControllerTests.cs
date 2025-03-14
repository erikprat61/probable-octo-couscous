using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using WeatherApp.Services;
using Xunit;

namespace WeatherApp.Tests;

public class DIBugControllerIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public DIBugControllerIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Get_ReturnsServerError_WhenAnnouncementServiceNotRegistered()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/api/dibug");

        // Assert

        // This should fail with a 500 error because the controller creates an AnnouncementService
        // directly and tries to use it incorrectly
        Assert.Equal(HttpStatusCode.InternalServerError, response.StatusCode);

        var content = await response.Content.ReadAsStringAsync();
        var errorResponse = JsonSerializer.Deserialize<JsonElement>(content);

        // Verify we got an error message
        Assert.True(errorResponse.TryGetProperty("error", out _));
    }

    [Fact]
    public async Task GetFeatured_ReturnsSuccessfully_EvenWithoutAnnouncementService()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/api/dibug/featured");

        // Assert

        // This should work because it uses the correctly injected IWeatherService
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
