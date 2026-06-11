using BookReader.Api.Data;
using BookReader.Api.Entities;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Implementations;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Implementations;
using BookReader.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

LoadDotEnv();

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<BookReaderDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterCors", policy =>
    {
        policy
            .WithOrigins(
                "http://localhost",
                "http://localhost:3000",
                "http://localhost:5000",
                "http://localhost:5102",
                "http://localhost:5173",
                "http://127.0.0.1",
                "http://10.0.2.2",
                "http://10.0.2.2:5102")
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddScoped<JwtHelper>();
builder.Services.AddHttpClient<IGoogleBooksService, GoogleBooksService>();

builder.Services.AddScoped<IAuthRepository, AuthRepository>();
builder.Services.AddScoped<IBookRepository, BookRepository>();
builder.Services.AddScoped<ILibraryRepository, LibraryRepository>();
builder.Services.AddScoped<IProgressRepository, ProgressRepository>();
builder.Services.AddScoped<IBookmarkRepository, BookmarkRepository>();
builder.Services.AddScoped<INoteRepository, NoteRepository>();
builder.Services.AddScoped<IMembershipRepository, MembershipRepository>();

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IBookService, BookService>();
builder.Services.AddScoped<ILibraryService, LibraryService>();
builder.Services.AddScoped<IProgressService, ProgressService>();
builder.Services.AddScoped<IBookmarkService, BookmarkService>();
builder.Services.AddScoped<INoteService, NoteService>();
builder.Services.AddScoped<IMembershipService, MembershipService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "Book Reader API",
        Version = "v1"
    });
});

var app = builder.Build();

await SeedAdminAsync(app.Services);

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("FlutterCors");

app.UseAuthorization();

app.MapControllers();

app.Run();

static async Task SeedAdminAsync(IServiceProvider services)
{
    var adminEmail = Environment.GetEnvironmentVariable("ADMIN_EMAIL")?.Trim();
    var adminPassword = Environment.GetEnvironmentVariable("ADMIN_PASSWORD")?.Trim();

    if (string.IsNullOrWhiteSpace(adminEmail) || string.IsNullOrWhiteSpace(adminPassword))
    {
        return;
    }

    using var scope = services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<BookReaderDbContext>();
    var existingAdmin = await dbContext.AppUsers.FirstOrDefaultAsync(
        user => user.Email == adminEmail);

    if (existingAdmin != null)
    {
        if (!string.Equals(existingAdmin.Role, "Admin", StringComparison.OrdinalIgnoreCase) ||
            !existingAdmin.IsActive)
        {
            existingAdmin.Role = "Admin";
            existingAdmin.IsActive = true;
            existingAdmin.UpdatedAt = DateTime.UtcNow;
            await dbContext.SaveChangesAsync();
        }

        return;
    }

    dbContext.AppUsers.Add(new AppUser
    {
        FullName = "Book Reader Admin",
        Email = adminEmail,
        PasswordHash = PasswordHasher.Hash(adminPassword),
        Role = "Admin",
        IsActive = true,
        CreatedAt = DateTime.UtcNow
    });
    await dbContext.SaveChangesAsync();
}

static void LoadDotEnv()
{
    var candidates = new[]
    {
        Path.Combine(Directory.GetCurrentDirectory(), ".env"),
        Path.Combine(AppContext.BaseDirectory, ".env")
    };

    var envPath = candidates.FirstOrDefault(File.Exists);
    if (envPath == null)
    {
        return;
    }

    foreach (var rawLine in File.ReadAllLines(envPath))
    {
        var line = rawLine.Trim();
        if (line.Length == 0 || line.StartsWith('#'))
        {
            continue;
        }

        var separatorIndex = line.IndexOf('=');
        if (separatorIndex <= 0)
        {
            continue;
        }

        var key = line[..separatorIndex].Trim();
        var value = line[(separatorIndex + 1)..].Trim().Trim('"');
        if (key.Length == 0)
        {
            continue;
        }

        Environment.SetEnvironmentVariable(key, value);
    }
}
