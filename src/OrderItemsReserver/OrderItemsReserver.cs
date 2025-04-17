using System.Text;
using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Http;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace OrderItemsReserver
{
    public class OrderItemsReserver
    {
        private readonly ILogger<OrderItemsReserver> _logger;
        private readonly BlobServiceClient _blobServiceClient;

        public OrderItemsReserver(ILogger<OrderItemsReserver> logger, BlobServiceClient blobServiceClient)
        {
            _logger = logger;
            _blobServiceClient = blobServiceClient;
        }

        [Function("OrderItemsReserver")]
        public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            try
            {
                // Read the request body asynchronously
                string requestBody;
                using (var reader = new StreamReader(req.Body, Encoding.UTF8))
                {
                    requestBody = await reader.ReadToEndAsync();
                }

                // Deserialize the request body to get order details
                var requestData = JsonConvert.DeserializeObject<RequestData>(requestBody);
                if (requestData == null || string.IsNullOrEmpty(requestData.OrderId))
                {
                    _logger.LogWarning("Invalid request body, missing OrderId.");
                    var badRequestResponse = req.CreateResponse(System.Net.HttpStatusCode.BadRequest);
                    await badRequestResponse.WriteStringAsync("Invalid request. Please provide a valid OrderId in the request body.");
                    return badRequestResponse;
                }

                string orderId = requestData.OrderId;

                // Create a blob container reference
                var containerClient = _blobServiceClient.GetBlobContainerClient("orders");
                await containerClient.CreateIfNotExistsAsync();

                // Create a blob reference
                var blobClient = containerClient.GetBlobClient($"{orderId}.json");

                // Upload the JSON data to the blob (save request body as-is)
                using (var stream = new MemoryStream(Encoding.UTF8.GetBytes(requestBody)))
                {
                    await blobClient.UploadAsync(stream, overwrite: true);
                }

                _logger.LogInformation($"Order {orderId} has been saved to blob storage.");

                // Return a success response
                var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
                await response.WriteAsJsonAsync(new { OrderId = orderId, Message = "Order created successfully." });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError($"An error occurred while processing the request: {ex.Message}", ex);

                var errorResponse = req.CreateResponse(System.Net.HttpStatusCode.InternalServerError);
                await errorResponse.WriteStringAsync("An error occurred while creating the order.");
                return errorResponse;
            }
        }

        // Helper Class to Deserialize Request Body
        public class RequestData
        {
            public required string OrderId { get; set; }
        }
    }
}
