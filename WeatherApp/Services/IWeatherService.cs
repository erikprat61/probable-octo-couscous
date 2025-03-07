using WeatherApp.Models;

namespace WeatherApp.Services;

public interface IWeatherService
{
    Task<IEnumerable<WeatherForecast>> GetForecastsAsync(int days);
    Task<WeatherForecast?> GetForecastByIdAsync(int id);
    Task<WeatherSummary> GetWeatherSummaryAsync(DateOnly startDate, DateOnly endDate);
}
