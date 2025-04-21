using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using System.Text.Json;
using MongoDB.Driver;
using Microsoft.Extensions.Logging;

public class OrderItem
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public string OrderId { get; set; } // This will be our shard key
    public string ProductId { get; set; }
    // Add other properties as needed
}
public class OrderItemSave
{
    [Function("OrderItemSave")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequestData req,
        FunctionContext executionContext)
    {
        var logger = executionContext.GetLogger("OrderItemSave");
        logger.LogInformation("OrderItemSave function triggered.");

        try
        {
            // Read the request body
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var orderItem = JsonSerializer.Deserialize<OrderItem>(requestBody);

            // Validate the input
            if (orderItem == null || string.IsNullOrEmpty(orderItem.OrderId))
            {
                var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
                await badResponse.WriteAsJsonAsync(new { message = "Invalid JSON or missing OrderId. OrderId is required." });
                return badResponse;
            }

            // MongoDB connection details
            string connectionString = Environment.GetEnvironmentVariable("CosmosMongoDbConnection");
            string databaseName = Environment.GetEnvironmentVariable("DatabaseName");
            string collectionName = Environment.GetEnvironmentVariable("CollectionName");

            // Initialize the MongoDB client
            var client = new MongoClient(connectionString);
            var database = client.GetDatabase(databaseName);
            var collection = database.GetCollection<OrderItem>(collectionName);

            // Create index for shard key if it doesn't exist
            var indexKeysDefinition = Builders<OrderItem>.IndexKeys.Ascending(x => x.OrderId);
            var createIndexModel = new CreateIndexModel<OrderItem>(indexKeysDefinition);
            await collection.Indexes.CreateOneAsync(createIndexModel);


            // Insert the order item into the collection
            await collection.InsertOneAsync(orderItem);

            logger.LogInformation("Order item successfully saved to MongoDB.");

            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(new { message = "Order item saved successfully.", id = orderItem.Id });
            return response;
        }
        catch (Exception ex)
        {
            logger.LogError($"An error occurred: {ex.Message}");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteAsJsonAsync(new { message = "An internal server error occurred." });
            return errorResponse;
        }
    }
}
