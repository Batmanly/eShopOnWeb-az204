﻿using System.Text;
using System.Text.Json;
using Ardalis.GuardClauses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;
using Microsoft.eShopWeb.ApplicationCore.Exceptions;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.eShopWeb.Infrastructure.Identity;
using Microsoft.eShopWeb.Web.Interfaces;
using Microsoft.Azure.ServiceBus;


namespace Microsoft.eShopWeb.Web.Pages.Basket;

[Authorize]
public class CheckoutModel : PageModel
{
    private readonly IBasketService _basketService;
    private readonly SignInManager<ApplicationUser> _signInManager;
    private readonly IOrderService _orderService;
    private string? _username = null;
    private readonly IBasketViewModelService _basketViewModelService;
    private readonly IAppLogger<CheckoutModel> _logger;

    public CheckoutModel(IBasketService basketService,
        IBasketViewModelService basketViewModelService,
        SignInManager<ApplicationUser> signInManager,
        IOrderService orderService,
        IAppLogger<CheckoutModel> logger)
    {
        _basketService = basketService;
        _signInManager = signInManager;
        _orderService = orderService;
        _basketViewModelService = basketViewModelService;
        _logger = logger;
    }

    public BasketViewModel BasketModel { get; set; } = new BasketViewModel();

    public async Task OnGet()
    {
        await SetBasketModelAsync();
    }

    public async Task<IActionResult> OnPost(IEnumerable<BasketItemViewModel> items)
    {
        try
        {
            await SetBasketModelAsync();

            if (!ModelState.IsValid)
            {
                return BadRequest();
            }

            var updateModel = items.ToDictionary(b => b.Id.ToString(), b => b.Quantity);
            await _basketService.SetQuantities(BasketModel.Id, updateModel);

            var orderAddress = new Address("123 Main St.", "Kent", "OH", "United States", "44240");
            await _orderService.CreateOrderAsync(BasketModel.Id, orderAddress);

            // Prepare order details for external API call

            // create uniq order id

            var orderId = Guid.NewGuid().ToString();

            var orderDetails = new
            {
                OrderId = orderId,
                BasketId = BasketModel.Id,
                BuyerId = BasketModel.BuyerId,
                Items = BasketModel.Items.Select(i => new
                {
                    i.Id,
                    i.ProductName,
                    i.Quantity,
                    i.UnitPrice
                }),
                ShippingAddress = new
                {
                    orderAddress.Street,
                    orderAddress.City,
                    orderAddress.State,
                    orderAddress.Country,
                    orderAddress.ZipCode
                }
            };


            var jsonContent = new StringContent(JsonSerializer.Serialize(orderDetails), Encoding.UTF8, "application/json");

            // Get URL from environment variable
            // This should be set in your Azure Function App settings
            //var url = Environment.GetEnvironmentVariable("OrderItemsReserverUrl");
            var url2 = Environment.GetEnvironmentVariable("OrderItemsSaveUrl");
            var ServiceBusQueueName = Environment.GetEnvironmentVariable("ServiceBusQueueName");
            var ServiceBusConnectionString = Environment.GetEnvironmentVariable("ServiceBusConnectionString");

            var queueClient = new QueueClient(ServiceBusConnectionString, ServiceBusQueueName);
            var message = new Message(Encoding.UTF8.GetBytes(JsonSerializer.Serialize(orderDetails)))
            {
                ContentType = "application/json",
                Label = "OrderDetails",
                MessageId = orderId
            };

            // Send the message to the queue
            await queueClient.SendAsync(message);
            _logger.LogInformation("Order details sent to Service Bus queue: {QueueName}", ServiceBusQueueName);
            // Close the client after sending the message
            await queueClient.CloseAsync();


            //// Make external API call
            //using (var httpClient = new HttpClient())
            //{
            //    //var response = await httpClient.PostAsync("https://az204-wfa-orderitemreserver-2025-dev.azurewebsites.net/api/OrderItemsReserver", jsonContent);
            //    var response = await httpClient.PostAsync(url, jsonContent);
            //    if (!response.IsSuccessStatusCode)
            //    {
            //        _logger.LogWarning("Failed to send order details to external API. Status Code: {StatusCode}", response.StatusCode);
            //        //return StatusCode((int)response.StatusCode);
            //    }
            //}

            //Save order details to Cosmos DB

            using (var httpClient = new HttpClient())
            {
                var response = await httpClient.PostAsync(url2, jsonContent);
                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning("Failed to save order details to Cosmos DB. Status Code: {StatusCode}", response.StatusCode);
                    //return StatusCode((int)response.StatusCode);
                }
            }

            await _basketService.DeleteBasketAsync(BasketModel.Id);
        }
        catch (EmptyBasketOnCheckoutException emptyBasketOnCheckoutException)
        {
            _logger.LogWarning(emptyBasketOnCheckoutException.Message);
            return RedirectToPage("/Basket/Index");
        }

        return RedirectToPage("Success");
    }

    private async Task SetBasketModelAsync()
    {
        Guard.Against.Null(User?.Identity?.Name, nameof(User.Identity.Name));
        if (_signInManager.IsSignedIn(HttpContext.User))
        {
            BasketModel = await _basketViewModelService.GetOrCreateBasketForUser(User.Identity.Name);
        }
        else
        {
            GetOrSetBasketCookieAndUserName();
            BasketModel = await _basketViewModelService.GetOrCreateBasketForUser(_username!);
        }
    }

    private void GetOrSetBasketCookieAndUserName()
    {
        if (Request.Cookies.ContainsKey(Constants.BASKET_COOKIENAME))
        {
            _username = Request.Cookies[Constants.BASKET_COOKIENAME];
        }
        if (_username != null) return;

        _username = Guid.NewGuid().ToString();
        var cookieOptions = new CookieOptions();
        cookieOptions.Expires = DateTime.Today.AddYears(10);
        Response.Cookies.Append(Constants.BASKET_COOKIENAME, _username, cookieOptions);
    }


}
