using WeatherApp.Services;
using Xunit;

namespace WeatherApp.Tests;

public class WeatherServiceTests
{
    [Fact]
    public void GetFeaturedForecasts_ShouldReturnOnlyFeaturedItems()
    {
        // Arrange
        var weatherService = new WeatherService();
        
        // Act
        var allForecasts = weatherService.GetAllForecasts().ToList();
        var featuredForecasts = weatherService.GetFeaturedForecasts().ToList();
        
        // Assert
        // There should be exactly 3 featured forecasts in our test data
        Assert.Equal(3, featuredForecasts.Count);
        
        // All returned forecasts should have IsFeatured=true
        Assert.True(featuredForecasts.All(f => f.IsFeatured), 
            "All returned forecasts should have IsFeatured=true. The filtering is not working correctly.");
        
        // The total count should be 8 (our sample data size)
        Assert.Equal(8, allForecasts.Count);
    }
}