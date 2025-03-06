var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure Kestrel for Codespaces environment to prevent HTTPS errors
if (Environment.GetEnvironmentVariable("CODESPACES")?.Equals("true", StringComparison.OrdinalIgnoreCase) == true)
{
    builder.WebHost.ConfigureKestrel(options =>
    {
        // Try to use port from environment variable first, or try 5000
        var port = int.TryParse(Environment.GetEnvironmentVariable("PORT"), out var envPort) 
            ? envPort 
            : 5000;
            
        try
        {
            options.ListenAnyIP(port); // HTTP only
            Console.WriteLine($"Application listening on port {port}");
        }
        catch (System.IO.IOException)
        {
            // If port is in use, try a different port
            var randomPort = new Random().Next(8000, 9000);
            options.ListenAnyIP(randomPort);
            Console.WriteLine($"Default port {port} was in use, now listening on port {randomPort}");
        }
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