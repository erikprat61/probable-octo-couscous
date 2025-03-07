# Weather App Bug Hunt Interview Project

This project is designed as a template for creating programming interview exercises that test a candidate's ability to find and fix bugs related to:

1. Dependency Injection and Lifetime Scopes
2. LINQ Queries
3. Async Operations

## How to Use This Template

To create a bug-hunting exercise for candidates:

1. Modify `Program.cs` to introduce dependency injection bugs (e.g., change service lifetimes)
2. Modify `WeatherService.cs` to introduce LINQ query bugs
3. Modify `WeatherController.cs` to introduce async/await issues
4. Run the tests to verify they fail when the bugs are present

The failing tests will indicate to candidates what needs to be fixed.

## Common Bug Patterns to Introduce

### Dependency Injection Lifetime Bugs

- Register a service as Transient but use it in a Singleton context
- Register a scoped service with a singleton dependency
- Register ITimeService as Transient (instead of Singleton) to break the TimeServiceTests

### LINQ Query Bugs

- Add `.ToList()` or `.ToArray()` in the middle of a LINQ chain incorrectly
- Use GroupBy without proper ordering in the GetMostCommonSummary method
- Use FirstOrDefault without proper null checking
- Swap OrderBy and OrderByDescending to get wrong results

### Async Bugs

- Remove await keywords in controller methods
- Use Result or Wait() instead of await
- Return Task.FromResult() in blocking code
- Forget to use ConfigureAwait(false) in a library context

## Running the Project

- Use `dotnet build` to build the solution
- Use `dotnet test` to run the tests
- Use F5 in VS Code to run and debug the application

## Tests Included

- Unit tests for WeatherController
- Integration tests with WebApplicationFactory
- Service tests for WeatherService
- TimeService tests to verify DI behavior
