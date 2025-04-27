using System;
using System.IO;
using System.Net.Http;
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

        private readonly string _logicAppUrl = Environment.GetEnvironmentVariable("LogicAppTriggerUrl");
        private const int RetryAttempts = 3; // Retry limits for blob storage
        private const int MaxDeliveryCount = 3; // Max delivery count for Service Bus messages

        public OrderItemsReserverServiceBus(ILogger<OrderItemsReserverServiceBus> logger, BlobServiceClient blobServiceClient)
        {
            _logger = logger;
            _blobServiceClient = blobServiceClient;
        }

        [Function(nameof(OrderItemsReserverServiceBus))]
        public async Task Run(
            [ServiceBusTrigger("az204-orders-queue-2025-dev", Connection = "ServiceBusConnectionString", AutoCompleteMessages = false)]
            ServiceBusReceivedMessage message,
            ServiceBusMessageActions messageActions)
        {
            try
            {
                _logger.LogInformation("Processing message with ID: {MessageId} | DeliveryCount: {DeliveryCount}", message.MessageId, message.DeliveryCount);

                // Extract the message body
                string requestBody = message.Body.ToString();

                // Deserialize the message body to fetch the OrderId
                var order = JsonSerializer.Deserialize<Order>(requestBody);
                if (order == null || string.IsNullOrEmpty(order.OrderId))
                {
                    throw new InvalidOperationException("OrderId is missing or invalid in the received message.");
                }

                string orderId = order.OrderId;
                _logger.LogInformation("Saving order {OrderId} to blob storage...", orderId);

                // Save the data to Azure Blob Storage with retry policy
                await UploadToBlobWithRetriesAsync(containerName: "orders", blobName: $"{orderId}.json", content: requestBody);

                // Successfully complete the message on success
                await messageActions.CompleteMessageAsync(message);
                _logger.LogInformation($"Message {message.MessageId} has been completed successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while processing the message with ID {MessageId} | DeliveryCount: {DeliveryCount}", message.MessageId, message.DeliveryCount);

                // Trigger Logic App only on final delivery attempt
                if (message.DeliveryCount >= MaxDeliveryCount)
                {
                    _logger.LogWarning("Message {MessageId} has reached the maximum delivery attempts ({MaxDeliveryCount}). Triggering Logic App...", message.MessageId, MaxDeliveryCount);

                    // Avoid async overlapping: Trigger Logic App only once
                    await TriggerLogicAppAsync(message);
                }

                // Abandon the message to allow retry unless it's the last attempt
                try
                {
                    await messageActions.AbandonMessageAsync(message);
                }
                catch (Exception abandonEx)
                {
                    _logger.LogError(abandonEx, "Failed to abandon message with ID {MessageId}", message.MessageId);
                }
            }
        }

        private async Task UploadToBlobWithRetriesAsync(string containerName, string blobName, string content)
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            int attempt = 0;

            while (attempt < RetryAttempts)
            {
                try
                {
                    // Ensure the container exists
                    await containerClient.CreateIfNotExistsAsync();

                    // Upload the blob
                    var blobClient = containerClient.GetBlobClient(blobName);
                    using var stream = new MemoryStream(Encoding.UTF8.GetBytes(content));
                    await blobClient.UploadAsync(stream, overwrite: true);

                    _logger.LogInformation("Successfully uploaded to blob storage on attempt {Attempt}.", attempt + 1);
                    return; // Exit the method when successful
                }
                catch (Azure.RequestFailedException ex) when (ex.ErrorCode == "ContainerBeingDeleted")
                {
                    attempt++;
                    _logger.LogWarning("Blob container is being deleted (Attempt {Attempt}/{MaxAttempts}). Retrying in {DelaySeconds} seconds...",
                        attempt, RetryAttempts, Math.Pow(2, attempt));

                    if (attempt >= RetryAttempts)
                    {
                        _logger.LogError("All retry attempts failed due to 'ContainerBeingDeleted'.");
                        throw new InvalidOperationException($"Blob container {containerName} is being deleted. Cannot upload blob.", ex);
                    }

                    // Exponential backoff delay
                    await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, attempt)));
                }
                catch (Exception ex)
                {
                    attempt++;
                    _logger.LogWarning("Failed to upload to blob storage (Attempt {Attempt}/{MaxAttempts}). Error: {ErrorMessage}", attempt, RetryAttempts, ex.Message);

                    if (attempt >= RetryAttempts)
                    {
                        _logger.LogError("All retry attempts failed for uploading to blob storage.");
                        throw; // Rethrow exception after exhausting retries
                    }

                    // Exponential backoff delay
                    await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, attempt)));
                }
            }
        }

        private async Task TriggerLogicAppAsync(ServiceBusReceivedMessage message)
        {
            if (string.IsNullOrEmpty(_logicAppUrl))
            {
                _logger.LogError("Logic App URL is not configured. Unable to trigger Logic App.");
                return;
            }

            try
            {
                using var httpClient = new HttpClient();

                // Prepare the message body payload to send to Logic App
                var requestContent = new StringContent(message.Body.ToString(), Encoding.UTF8, "application/json");

                // Send POST request to the Logic App
                var response = await httpClient.PostAsync(_logicAppUrl, requestContent);

                if (response.IsSuccessStatusCode)
                {
                    _logger.LogInformation("Logic App triggered successfully for message ID {MessageId}.", message.MessageId);
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

        private class Order
        {
            [JsonPropertyName("OrderId")]
            public string OrderId { get; set; }

            // Add other properties as needed
        }
    }
}
