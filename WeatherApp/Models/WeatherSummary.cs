namespace WeatherApp.Models;

public class WeatherSummary
{
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public double AverageTemperatureC { get; set; }
    public double AverageTemperatureF => 32 + (AverageTemperatureC / 0.5556);
    public string? OverallSummary { get; set; }
}
