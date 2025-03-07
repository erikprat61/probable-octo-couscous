using WeatherApp.Models;

namespace WeatherApp.Repositories;

public class WeatherRepository : IWeatherRepository
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly List<WeatherForecast> _forecasts;

    public WeatherRepository()
    {
        // Initialize with some sample data
        var random = new Random();
        _forecasts = Enumerable.Range(1, 100).Select(index => new WeatherForecast
        {
            Id = index,
            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            TemperatureC = random.Next(-20, 55),
            Summary = Summaries[random.Next(Summaries.Length)]
        }).ToList();
    }

    public async Task<IEnumerable<WeatherForecast>> GetForecastsAsync(int count)
    {
        // Simulate async operation
        await Task.Delay(10);
        return _forecasts.Take(count);
    }

    public async Task<WeatherForecast?> GetForecastByIdAsync(int id)
    {
        // Simulate async operation
        await Task.Delay(10);
        return _forecasts.FirstOrDefault(f => f.Id == id);
    }

    public async Task<IEnumerable<WeatherForecast>> GetForecastsInRangeAsync(DateOnly startDate, DateOnly endDate)
    {
        // Simulate async operation
        await Task.Delay(10);
        return _forecasts.Where(f => f.Date >= startDate && f.Date <= endDate);
    }
}
