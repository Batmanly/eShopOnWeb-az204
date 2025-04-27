using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.Extensions.Hosting;
using Azure.Storage.Blobs;
using Microsoft.Extensions.DependencyInjection;

var builder = FunctionsApplication.CreateBuilder(args);
builder.Services.AddHttpClient();
builder.Services.AddLogging();

builder.Services.AddSingleton(x =>
{
    //string? storageConnectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
    //if (string.IsNullOrEmpty(storageConnectionString))
    //{
    //    throw new InvalidOperationException("AzureWebJobsStorage environment variable is not set.");
    //}
    //return new BlobServiceClient(storageConnectionString);
    string? storageConnectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
    if (string.IsNullOrEmpty(storageConnectionString))
    {
        throw new InvalidOperationException("AzureWebJobsStorage environment variable is not set.");
    }
    try
    {
        return new BlobServiceClient(storageConnectionString);
    }
    catch (Exception ex)
    {
        //throw new InvalidOperationException("Failed to create BlobServiceClient.", ex);
        return null;
    }
});

builder.Build().Run();
