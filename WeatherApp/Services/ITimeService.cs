namespace WeatherApp.Services;

public interface ITimeService
{
    DateTime GetCurrentTime();
    string GetTimeStamp();
}
