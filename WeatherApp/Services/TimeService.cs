namespace WeatherApp.Services;

// This service demonstrates the DI lifetime scope issues
public class TimeService : ITimeService
{
    private readonly DateTime _creationTime;

    public TimeService()
    {
        _creationTime = DateTime.UtcNow;
    }

    public DateTime GetCurrentTime() => DateTime.UtcNow;

    public string GetTimeStamp() => _creationTime.ToString("o");
}
