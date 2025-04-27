using System;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using Azure.Storage.Blobs;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace OrderItemsReserverServiceBus
{
    public class OrderItemsReserverServiceBus
    {
        private readonly ILogger<OrderItemsReserverServiceBus> _logger;
        private readonly BlobServiceClient _blobServiceClient;

        // Get the connection string from environment variables
        private readonly string _logicAppUrl = Environment.GetEnvironmentVariable("LogicAppTriggerUrl");
        private const int RetryAttempts = 3; // Specify how many retries to attempt

        public OrderItemsReserverServiceBus(ILogger<OrderItemsReserverServiceBus> logger, BlobServiceClient blobServiceClient)
        {
            _logger = logger;
            _blobServiceClient = blobServiceClient;
        }

        [Function(nameof(OrderItemsReserverServiceBus))]
        public async Task Run(
            [ServiceBusTrigger("az204-orders-queue-2025-dev", Connection = "ServiceBusConnectionString")]
            ServiceBusReceivedMessage message,
            ServiceBusMessageActions messageActions)
        {
            try
            {
                _logger.LogInformation("Processing message with ID: {MessageId}", message.MessageId);

                // Extract the order JSON body
                string requestBody = message.Body.ToString();

                // Deserialize the request body to fetch the OrderId
                var order = JsonSerializer.Deserialize<Order>(requestBody);
                if (order == null || string.IsNullOrEmpty(order.OrderId))
                {
                    throw new InvalidOperationException("OrderId is missing or invalid in the received message.");
                }

                string orderId = order.OrderId; // Use the provided OrderId

                _logger.LogInformation("Saving order {OrderId} to blob storage...", orderId);

                // Save order data to Azure Blob Storage with retry policy
                await UploadToBlobWithRetriesAsync(containerName: "orders", blobName: $"{orderId}.json", content: requestBody);

                // Complete message processing
                await messageActions.CompleteMessageAsync(message);
                _logger.LogInformation($"Message {message.MessageId} has been completed.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while processing the message.");

                // Trigger Logic App in case of a Service Bus connection issue
                if (!string.IsNullOrEmpty(_logicAppUrl))
                {
                    try
                    {
                        using var httpClient = new System.Net.Http.HttpClient();
                        var response = await httpClient.PostAsync(_logicAppUrl, new System.Net.Http.StringContent($"{{\"error\":\"{ex.Message}\"}}", Encoding.UTF8, "application/json"));

                        if (response.IsSuccessStatusCode)
                        {
                            _logger.LogInformation("Logic App triggered successfully.");
                        }
                        else
                        {
                            _logger.LogError("Failed to trigger Logic App. Status Code: {StatusCode}, Reason: {Reason}", response.StatusCode, response.ReasonPhrase);
                        }
                    }
                    catch (Exception e)
                    {
                        _logger.LogError(e, "Error while attempting to trigger the Logic App.");
                    }
                }
                else
                {
                    _logger.LogError("Logic App URL is not configured. Unable to trigger Logic App.");
                }

                try
                {
                    // Abandon the message so it can be retried later
                    await messageActions.AbandonMessageAsync(message);
                }
                catch (Exception abandonEx)
                {
                    _logger.LogError(abandonEx, "Failed to abandon message: {MessageId}", message.MessageId);
                }
            }
        }

        // Method to upload to Blob Storage with a retry mechanism
        private async Task UploadToBlobWithRetriesAsync(string containerName, string blobName, string content)
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            await containerClient.CreateIfNotExistsAsync();

            var blobClient = containerClient.GetBlobClient(blobName);

            int attempt = 0;
            while (attempt < RetryAttempts)
            {
                try
                {
                    using (var stream = new MemoryStream(Encoding.UTF8.GetBytes(content)))
                    {
                        await blobClient.UploadAsync(stream, overwrite: true);
                    }

                    _logger.LogInformation("Successfully uploaded to blob storage on attempt {Attempt}.", attempt + 1);
                    return; // Exit if the upload succeeds
                }
                catch (Exception ex)
                {
                    attempt++;
                    _logger.LogWarning("Failed to upload to blob storage (attempt {Attempt}/{MaxAttempts}). Error: {Message}", attempt, RetryAttempts, ex.Message);

                    if (attempt >= RetryAttempts)
                    {
                        _logger.LogError("All retry attempts failed for uploading to blob storage.");
                        throw; // Rethrow the exception after exhausting retries
                    }

                    // Implement exponential backoff delay
                    int delayInSeconds = (int)Math.Pow(2, attempt); // Exponential backoff
                    await Task.Delay(TimeSpan.FromSeconds(delayInSeconds));
                }
            }
        }

        // Define a helper class to deserialize the incoming JSON
        private class Order
        {
            [JsonPropertyName("OrderId")]
            public string OrderId { get; set; }

            // Other properties can also be added here if needed
        }
    }
}
