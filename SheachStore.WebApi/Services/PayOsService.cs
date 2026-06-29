using Net.payOS;
using Net.payOS.Types;
using SheachStore.WebApi.Dtos;

namespace SheachStore.WebApi.Services;

public sealed class PayOsService : IPayOsService
{
    private readonly IConfiguration _configuration;
    private readonly PayOS _payOsClient;

    public PayOsService(IConfiguration configuration)
    {
        _configuration = configuration;
        _payOsClient = new PayOS(
            RequireSetting("PayOs:ClientId"),
            RequireSetting("PayOs:ApiKey"),
            RequireSetting("PayOs:ChecksumKey"));
    }

    public async Task<PayOsCheckoutResponse> CreateCheckoutAsync(int orderId, decimal amount, string description, CancellationToken cancellationToken)
    {
        var total = Convert.ToInt32(Math.Round(amount, MidpointRounding.AwayFromZero));
        var paymentRequest = new PaymentData(
            orderId,
            total,
            Truncate(description, 25),
            new List<ItemData>
            {
                new("Order total", 1, total)
            },
            RequireSetting("PayOs:CancelUrl"),
            RequireSetting("PayOs:ReturnUrl"));

        var paymentLink = await _payOsClient.createPaymentLink(paymentRequest);
        return new PayOsCheckoutResponse(orderId, paymentLink.checkoutUrl, paymentLink.qrCode);
    }

    public bool VerifyWebhookSignature(PayOsWebhookRequest request)
    {
        return request.Data is not null;
    }

    private string RequireSetting(string key)
    {
        return _configuration[key] ?? throw new InvalidOperationException($"Missing configuration value: {key}");
    }

    private static string Truncate(string value, int maxLength) => value.Length <= maxLength ? value : value[..maxLength];
}
