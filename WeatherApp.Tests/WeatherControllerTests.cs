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
