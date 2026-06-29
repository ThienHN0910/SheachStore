using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SheachStore.WebApi.Data;
using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Controllers;

[ApiController]
[AllowAnonymous]
[Route("payos")]
public class PayOsController : ControllerBase
{
    [AcceptVerbs("GET", "POST")]
    [Route("return")]
    public ContentResult Return()
    {
        return Content("""
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Payment success</title>
  </head>
  <body style="font-family: Arial, sans-serif; padding: 24px;">
    <h2>Thanh toán thành công</h2>
    <p>Bạn có thể quay lại ứng dụng để kiểm tra đơn hàng.</p>
  </body>
</html>
""", "text/html");
    }

    [AcceptVerbs("GET", "POST")]
    [Route("cancel")]
    public async Task<IActionResult> Cancel([FromQuery] int? orderCode, [FromServices] AppDbContext dbContext, CancellationToken cancellationToken)
    {
        if (orderCode.HasValue)
        {
            var order = await dbContext.Orders.Include(o => o.OrderItems).FirstOrDefaultAsync(o => o.Id == orderCode.Value, cancellationToken);
            if (order is not null && order.Status == OrderStatus.Pending)
            {
                order.Status = OrderStatus.Cancelled;
                foreach (var item in order.OrderItems)
                {
                    var book = await dbContext.Books.FindAsync(new object[] { item.BookId }, cancellationToken);
                    if (book is not null)
                    {
                        book.Stock += item.Quantity;
                    }
                }
                await dbContext.SaveChangesAsync(cancellationToken);
            }
        }

        return Content("""
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Payment cancelled</title>
  </head>
  <body style="font-family: Arial, sans-serif; padding: 24px;">
    <h2>Thanh toán đã bị hủy</h2>
    <p>Bạn có thể quay lại ứng dụng để thử lại.</p>
  </body>
</html>
""", "text/html");
    }
}
