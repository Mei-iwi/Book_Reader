using BookReader.Api.Data;
using BookReader.Api.Helpers;
using BookReader.Api.Repositories.Implementations;
using BookReader.Api.Repositories.Interfaces;
using BookReader.Api.Services.Implementations;
using BookReader.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

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
                "http://localhost:5173",
                "http://127.0.0.1",
                "http://10.0.2.2")
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
