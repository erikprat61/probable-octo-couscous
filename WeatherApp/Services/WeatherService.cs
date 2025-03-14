using WeatherApp.Models;

namespace WeatherApp.Services;

public interface IWeatherService
{
    /// <summary>
    /// Gets all available weather forecasts
    /// </summary>
    IEnumerable<WeatherForecast> GetAllForecasts();

    /// <summary>
    /// Gets only featured weather forecasts
    /// </summary>
    IEnumerable<WeatherForecast> GetFeaturedForecasts();
}

public class WeatherService : IWeatherService
{
    /// <summary>
    /// Gets all available weather forecasts
    /// </summary>
    public IEnumerable<WeatherForecast> GetAllForecasts()
    {
        return _forecasts.ToList();
    }

    /// <summary>
    /// Gets only featured weather forecasts
    /// </summary>
    public IEnumerable<WeatherForecast> GetFeaturedForecasts()
    {
        // Get all forecasts
        var allForecasts = _forecasts.ToList();

        var featuredForecasts = allForecasts;

        return featuredForecasts;
    }

    private static readonly List<WeatherForecast> _forecasts = new List<WeatherForecast>
    {
        new WeatherForecast { Date = DateTime.Now.AddDays(1), TemperatureC = -20, Summary = "Freezing", IsFeatured = true },
        new WeatherForecast { Date = DateTime.Now.AddDays(2), TemperatureC = -10, Summary = "Bracing", IsFeatured = false },
        new WeatherForecast { Date = DateTime.Now.AddDays(3), TemperatureC = 0, Summary = "Chilly", IsFeatured = false },
        new WeatherForecast { Date = DateTime.Now.AddDays(4), TemperatureC = 10, Summary = "Cool", IsFeatured = true },
        new WeatherForecast { Date = DateTime.Now.AddDays(5), TemperatureC = 20, Summary = "Mild", IsFeatured = false },
        new WeatherForecast { Date = DateTime.Now.AddDays(6), TemperatureC = 30, Summary = "Warm", IsFeatured = false },
        new WeatherForecast { Date = DateTime.Now.AddDays(7), TemperatureC = 40, Summary = "Hot", IsFeatured = true },
        new WeatherForecast { Date = DateTime.Now.AddDays(8), TemperatureC = 50, Summary = "Scorching", IsFeatured = false },
    };
}