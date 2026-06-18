namespace SheachStore.WebApi.Models;

public enum OrderStatus
{
    Pending = 1,
    Paid = 2,
    Processing = 3,
    Shipped = 4,
    Completed = 5,
    Cancelled = 6
}
