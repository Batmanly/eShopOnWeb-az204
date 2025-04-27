using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using System.Text.Json;
using MongoDB.Driver;
using Microsoft.Extensions.Logging;
using System.Text;
using Newtonsoft.Json;
using MongoDB.Bson;


public class OrderItemSave
{
    private readonly ILogger<OrderItemSave> _logger;
    private readonly MongoClient _mongoClient;
    private readonly IMongoDatabase _database;
    private readonly string _connectionString;
    private readonly string _databaseName;
    private readonly string _collectionName;
    private readonly string _shardKey;

    public OrderItemSave(ILogger<OrderItemSave> logger)
    {
        _logger = logger;
        _connectionString = Environment.GetEnvironmentVariable("CosmosMongoDbConnection") ?? throw new ArgumentNullException(nameof(_connectionString));
        _databaseName = Environment.GetEnvironmentVariable("DatabaseName") ?? throw new ArgumentNullException(nameof(_databaseName));
        _collectionName = Environment.GetEnvironmentVariable("CollectionName") ?? throw new ArgumentNullException(nameof(_collectionName));
        _shardKey = Environment.GetEnvironmentVariable("ShardKey") ?? throw new ArgumentNullException(nameof(_shardKey));
        _mongoClient = new MongoClient(_connectionString);
        _database = _mongoClient.GetDatabase(_databaseName);
    }

    [Function("OrderItemSave")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequestData req,
        FunctionContext executionContext)
    {
        var logger = executionContext.GetLogger("OrderItemSave");
        logger.LogInformation("OrderItemSave function triggered.");

        try
        {
            string requestBody;
            using (var reader = new StreamReader(req.Body, Encoding.UTF8))
            {
                requestBody = await reader.ReadToEndAsync();
            }

            var requestData = JsonConvert.DeserializeObject<RequestData>(requestBody);
            if (requestData == null || string.IsNullOrEmpty(requestData.OrderId))
            {
                _logger.LogWarning("Invalid request body, missing OrderId.");
                var badRequestResponse = req.CreateResponse(HttpStatusCode.BadRequest);
                await badRequestResponse.WriteStringAsync("Invalid request. Please provide a valid OrderId in the request body.");
                return badRequestResponse;
            }

            string orderId = requestData.OrderId;

            _logger.LogInformation($"Order {orderId} has been received.");

            var collection = _database.GetCollection<BsonDocument>(_collectionName);
            var document = BsonDocument.Parse(requestBody);

            // Ensure no duplicate 'OrderId' element is added
            if (!document.Contains(_shardKey))
            {
                document.Add(new BsonElement(_shardKey, orderId));
            }

            await collection.InsertOneAsync(document);

            logger.LogInformation("Order item successfully saved to MongoDB.");

            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(new { OrderId = orderId, Message = "Order created successfully." });

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

    public class RequestData
    {
        public required string OrderId { get; set; }
    }
}
