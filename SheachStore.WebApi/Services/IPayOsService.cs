using SheachStore.WebApi.Dtos;

namespace SheachStore.WebApi.Services;

public interface IPayOsService
{
    Task<PayOsCheckoutResponse> CreateCheckoutAsync(int orderId, decimal amount, string description, CancellationToken cancellationToken);
    bool VerifyWebhookSignature(PayOsWebhookRequest request);
}
