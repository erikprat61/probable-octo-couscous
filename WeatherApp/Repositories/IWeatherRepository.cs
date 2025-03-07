using WeatherApp.Models;

namespace WeatherApp.Repositories;

public interface IWeatherRepository
{
    Task<IEnumerable<WeatherForecast>> GetForecastsAsync(int count);
    Task<WeatherForecast?> GetForecastByIdAsync(int id);
    Task<IEnumerable<WeatherForecast>> GetForecastsInRangeAsync(DateOnly startDate, DateOnly endDate);
}
