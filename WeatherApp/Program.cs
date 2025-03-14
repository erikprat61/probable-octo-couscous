using WeatherApp.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSingleton<IWeatherService, WeatherService>();

// Configure Kestrel for Codespaces environment to prevent HTTPS errors
if (Environment.GetEnvironmentVariable("CODESPACES")?.Equals("true", StringComparison.OrdinalIgnoreCase) == true)
{
    builder.WebHost.ConfigureKestrel(options =>
    {
        options.ListenAnyIP(5000); // HTTP only
    });
}

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    
    // Add a redirect from the root URL to Swagger, but hide it from Swagger docs
    app.MapGet("/", () => Results.Redirect("/swagger"))
       .ExcludeFromDescription();
}

// Only use HTTPS redirection when not in Codespaces
if (Environment.GetEnvironmentVariable("CODESPACES")?.Equals("true", StringComparison.OrdinalIgnoreCase) != true)
{
    app.UseHttpsRedirection();
}

app.UseAuthorization();
app.MapControllers();

app.Run();

// Make the Program class public for testing
public partial class Program { }