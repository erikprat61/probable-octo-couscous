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
