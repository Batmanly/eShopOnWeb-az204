using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.Extensions.Hosting;
using Azure.Storage.Blobs;
using Microsoft.Extensions.DependencyInjection;

var builder = FunctionsApplication.CreateBuilder(args);

// Application Insights isn't enabled by default. See https://aka.ms/AAt8mw4.
// builder.Services
//     .AddApplicationInsightsTelemetryWorkerService()
//     .ConfigureFunctionsApplicationInsights();

// Register BlobServiceClient as a singleton service
builder.Services.AddSingleton(x =>
{
    string? storageConnectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
    if (string.IsNullOrEmpty(storageConnectionString))
    {
        throw new InvalidOperationException("AzureWebJobsStorage environment variable is not set.");
    }
    return new BlobServiceClient(storageConnectionString);
});

builder.Build().Run();
