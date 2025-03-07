using WeatherApp.Models;
using WeatherApp.Repositories;

namespace WeatherApp.Services;

public class WeatherService : IWeatherService
{
    private readonly IWeatherRepository _weatherRepository;
    private readonly ITimeService _timeService;

    public WeatherService(IWeatherRepository weatherRepository, ITimeService timeService)
    {
        _weatherRepository = weatherRepository;
        _timeService = timeService;
    }

    public async Task<IEnumerable<WeatherForecast>> GetForecastsAsync(int days)
    {
        // Log access time
        Console.WriteLine($"Weather data accessed at: {_timeService.GetTimeStamp()}");
        return await _weatherRepository.GetForecastsAsync(days);
    }

    public async Task<WeatherForecast?> GetForecastByIdAsync(int id)
    {
        return await _weatherRepository.GetForecastByIdAsync(id);
    }

    public async Task<WeatherSummary> GetWeatherSummaryAsync(DateOnly startDate, DateOnly endDate)
    {
        var forecasts = await _weatherRepository.GetForecastsInRangeAsync(startDate, endDate);
        
        return new WeatherSummary
        {
            StartDate = startDate,
            EndDate = endDate,
            AverageTemperatureC = forecasts.Average(f => f.TemperatureC),
            OverallSummary = GetMostCommonSummary(forecasts)
        };
    }

    private string? GetMostCommonSummary(IEnumerable<WeatherForecast> forecasts)
    {
        return forecasts
            .GroupBy(f => f.Summary)
            .OrderByDescending(g => g.Count())
            .Select(g => g.Key)
            .FirstOrDefault();
    }
}
