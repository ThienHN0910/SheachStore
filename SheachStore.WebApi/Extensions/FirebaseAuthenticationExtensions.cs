using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using SheachStore.WebApi.Models;

namespace SheachStore.WebApi.Extensions;

public static class FirebaseAuthenticationExtensions
{
    public static AuthenticationBuilder AddFirebaseAuthentication(this IServiceCollection services, string projectId)
    {
        return services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        })
        .AddJwtBearer(options =>
        {
            options.Authority = $"https://securetoken.google.com/{projectId}";
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = $"https://securetoken.google.com/{projectId}",
                ValidateAudience = true,
                ValidAudience = projectId,
                ValidateLifetime = true,
                // Định danh chính xác chuẩn Claims của Microsoft để [Authorize(Roles = ...)] hoạt động đúng
                RoleClaimType = System.Security.Claims.ClaimTypes.Role
            };

            options.Events = new JwtBearerEvents
            {
                OnTokenValidated = async context =>
                {
                    var principal = context.Principal;
                    var userId = principal?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
                                 ?? principal?.FindFirst("user_id")?.Value;
                    if (string.IsNullOrEmpty(userId)) return;

                    var userManager = context.HttpContext.RequestServices
                        .GetRequiredService<UserManager<User>>();

                    // Đọc trực tiếp từ Database để đảm bảo quyền (Role) luôn realtime
                    var user = await userManager.FindByIdAsync(userId);
                    
                    if (user == null)
                    {
                        var email = principal?.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value
                                    ?? principal?.FindFirst("email")?.Value
                                    ?? $"{userId}@firebase.local";
                        var fullName = principal?.FindFirst("name")?.Value ?? email.Split('@')[0];

                        user = new User
                        {
                            Id = userId,
                            UserName = email,
                            Email = email,
                            FullName = fullName,
                            Role = UserRole.Customer,
                            CreatedAt = DateTime.UtcNow,
                            EmailConfirmed = true
                        };
                        await userManager.CreateAsync(user);
                    }

                    // Thêm role claim từ database vào JWT Principal hiện tại
                    var roleString = user.Role.ToString();
                    var identity = context.Principal?.Identity as System.Security.Claims.ClaimsIdentity;
                    identity?.AddClaim(new System.Security.Claims.Claim(System.Security.Claims.ClaimTypes.Role, roleString));
                }
            };
        });
    }
}
