#!/bin/bash

# Exit on error
set -e

echo "Creating .NET 9 API project structure..."

# Create solution and projects
mkdir -p WeatherApp/Controllers
mkdir -p WeatherApp/Models
mkdir -p WeatherApp.Tests
mkdir -p .vscode
mkdir -p .devcontainer

# Create solution file
cat > WeatherApp.sln << 'EOF'
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "WeatherApp", "WeatherApp\WeatherApp.csproj", "{16A9FC7F-0CB3-4A09-9879-DD63F1D82D2D}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "WeatherApp.Tests", "WeatherApp.Tests\WeatherApp.Tests.csproj", "{63D83A2D-B2B5-48F3-8A3C-5B8869DCFF7A}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{16A9FC7F-0CB3-4A09-9879-DD63F1D82D2D}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{16A9FC7F-0CB3-4A09-9879-DD63F1D82D2D}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{16A9FC7F-0CB3-4A09-9879-DD63F1D82D2D}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{16A9FC7F-0CB3-4A09-9879-DD63F1D82D2D}.Release|Any CPU.Build.0 = Release|Any CPU
		{63D83A2D-B2B5-48F3-8A3C-5B8869DCFF7A}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{63D83A2D-B2B5-48F3-8A3C-5B8869DCFF7A}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{63D83A2D-B2B5-48F3-8A3C-5B8869DCFF7A}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{63D83A2D-B2B5-48F3-8A3C-5B8869DCFF7A}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
EndGlobal
EOF

# Create API project files
cat > WeatherApp/WeatherApp.csproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <InvariantGlobalization>true</InvariantGlobalization>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
  </ItemGroup>

</Project>
EOF

cat > WeatherApp/Program.cs << 'EOF'
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
EOF

# Create model for Weather Forecast
cat > WeatherApp/Models/WeatherForecast.cs << 'EOF'
namespace WeatherApp.Models;

public class WeatherForecast
{
    public DateTime Date { get; set; }
    
    public int TemperatureC { get; set; }
    
    public int TemperatureF => 32 + (int)(TemperatureC * 9 / 5);
    
    public string? Summary { get; set; }
}
EOF

cat > WeatherApp/Controllers/WeatherController.cs << 'EOF'
using Microsoft.AspNetCore.Mvc;
using WeatherApp.Models;

namespace WeatherApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WeatherController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    [HttpGet]
    public IActionResult Get()
    {
        var forecast = new WeatherForecast
        {
            Date = DateTime.Now,
            TemperatureC = 20,
            Summary = "Sunny"
        };
        
        return Ok(forecast);
    }
    
    [HttpGet("week")]
    public IActionResult GetWeekForecast()
    {
        var rng = new Random();
        var forecasts = Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateTime.Now.AddDays(index),
            TemperatureC = rng.Next(-20, 55),
            Summary = Summaries[rng.Next(Summaries.Length)]
        })
        .ToArray();
        
        return Ok(forecasts);
    }
}
EOF

# Create test project files
cat > WeatherApp.Tests/WeatherApp.Tests.csproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="9.0.0" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.9.0" />
    <PackageReference Include="xunit" Version="2.6.1" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.3">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\WeatherApp\WeatherApp.csproj" />
  </ItemGroup>

</Project>
EOF

cat > WeatherApp.Tests/WeatherControllerTests.cs << 'EOF'
using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace WeatherApp.Tests;

public class WeatherControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public WeatherControllerTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Get_ReturnsWeatherForecast()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/api/weather");
        var content = await response.Content.ReadAsStringAsync();
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        // Verify it contains the expected properties
        var forecast = JsonSerializer.Deserialize<JsonElement>(content);
        Assert.True(forecast.TryGetProperty("date", out _));
        Assert.True(forecast.TryGetProperty("temperatureC", out var tempC));
        Assert.True(forecast.TryGetProperty("temperatureF", out var tempF));
        Assert.True(forecast.TryGetProperty("summary", out var summary));
        
        // Check some basic values
        Assert.Equal(20, tempC.GetInt32());
        // 20°C should be approximately 68°F (the correct conversion is 68°F)
        Assert.Equal(68, tempF.GetInt32());
        Assert.Equal("Sunny", summary.GetString());
    }
    
    [Fact]
    public async Task GetWeekForecast_ReturnsMultipleForecasts()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/api/weather/week");
        var content = await response.Content.ReadAsStringAsync();
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        
        // Verify we get an array of forecasts
        var forecasts = JsonSerializer.Deserialize<JsonElement>(content);
        Assert.Equal(JsonValueKind.Array, forecasts.ValueKind);
        Assert.Equal(5, forecasts.GetArrayLength());
        
        // Check the first item has all required properties
        var firstItem = forecasts[0];
        Assert.True(firstItem.TryGetProperty("date", out _));
        Assert.True(firstItem.TryGetProperty("temperatureC", out _));
        Assert.True(firstItem.TryGetProperty("temperatureF", out _));
        Assert.True(firstItem.TryGetProperty("summary", out _));
    }
}
EOF

# Create .devcontainer configuration
cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "C# (.NET)",
  "image": "mcr.microsoft.com/devcontainers/dotnet:latest",
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": {
      "version": "9.0"
    }
  },
  "forwardPorts": [5000],
  "postCreateCommand": "chmod +x build.sh && ./build.sh",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-dotnettools.csharp",
        "ms-dotnettools.vscode-dotnet-runtime",
        "formulahendry.dotnet-test-explorer"
      ],
      "settings": {
        "omnisharp.enableRoslynAnalyzers": true,
        "omnisharp.enableEditorConfigSupport": true,
        "dotnet-test-explorer.testProjectPath": "**/*.Tests.csproj"
      }
    }
  }
}
EOF

# Create .vscode configuration
cat > .vscode/launch.json << 'EOF'
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": ".NET Launch (web)",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build",
      "program": "${workspaceFolder}/WeatherApp/bin/Debug/net9.0/WeatherApp.dll",
      "args": [],
      "cwd": "${workspaceFolder}/WeatherApp",
      "stopAtEntry": false,
      "serverReadyAction": {
        "action": "openExternally",
        "pattern": "\\bNow listening on:\\s+(https?://\\S+)",
        "uriFormat": "%s/swagger"
      },
      "env": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "ASPNETCORE_URLS": "http://localhost:5000",
        "CODESPACES": "true"
      },
      "sourceFileMap": {
        "/Views": "${workspaceFolder}/Views"
      }
    }
  ]
}
EOF

cat > .vscode/tasks.json << 'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "build",
      "command": "dotnet",
      "type": "process",
      "args": [
        "build",
        "${workspaceFolder}/WeatherApp.sln",
        "/property:GenerateFullPaths=true",
        "/consoleloggerparameters:NoSummary"
      ],
      "problemMatcher": "$msCompile"
    },
    {
      "label": "test",
      "command": "dotnet",
      "type": "process",
      "args": [
        "test",
        "${workspaceFolder}/WeatherApp.Tests/WeatherApp.Tests.csproj",
        "/property:GenerateFullPaths=true",
        "/consoleloggerparameters:NoSummary"
      ],
      "problemMatcher": "$msCompile",
      "group": {
        "kind": "test",
        "isDefault": true
      }
    }
  ]
}
EOF

# Add global.json to ensure .NET 9 usage
cat > global.json << 'EOF'
{
  "sdk": {
    "version": "9.0.100",
    "rollForward": "latestMajor"
  }
}
EOF

# Create .gitignore file for .NET projects
cat > .gitignore << 'EOF'
# Visual Studio / .NET specific
[Oo]bj/
[Bb]in/
.vs/
_UpgradeReport_Files/
[Pp]ackages/
*.user
*.suo
*.userprefs
*.usertasks
*.userosscache
*.sln.docstates
*.vspscc
*.vssscc
.builds
*.pidb
*.svclog
*.log
*_i.c
*_p.c
*.ilk
*.meta
*.obj
*.pch
*.pdb
*.pgc
*.pgd
*.rsp
*.sbr
*.tlb
*.tli
*.tlh
*.tmp
*.tmp_proj
*.vsidx
*_wpftmp.csproj
*.sqlite
*.sdf
*.opensdf
*.cachefile
*.VC.db
*.VC.VC.opendb
FakesAssemblies/

# .NET Core
project.lock.json
project.fragment.lock.json
artifacts/
**/Properties/launchSettings.json

# User-specific files
*.rsuser
*.suo
*.user
*.userosscache
*.sln.docstates

# Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
[Rr]eleases/
x64/
x86/
[Ww][Ii][Nn]32/
[Aa][Rr][Mm]/
[Aa][Rr][Mm]64/
bld/
[Bb]in/
[Oo]bj/
[Ll]og/
[Ll]ogs/

# NuGet Packages
*.nupkg
*.snupkg
**/[Pp]ackages/*
!**/[Pp]ackages/build/
*.nuget.props
*.nuget.targets

# JetBrains Rider
.idea/
*.sln.iml

# Visual Studio Code - explicitly include configuration files
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
*.code-workspace

# macOS
.DS_Store

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/
EOF

# Ensure .NET 9 is installed and active
echo "Checking .NET version..."
dotnet --info

echo "Building the solution..."
dotnet restore
dotnet build 
# Only run tests after build succeeds
if [ $? -eq 0 ]; then
  dotnet test
fi

echo "Setup complete! You can now launch the API using F5 or run tests with the 'Run Tests' button."