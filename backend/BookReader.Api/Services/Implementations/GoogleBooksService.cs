using System.Text.Json;
using BookReader.Api.DTOs.Books;
using BookReader.Api.Helpers;
using BookReader.Api.Services.Interfaces;

namespace BookReader.Api.Services.Implementations;

public class GoogleBooksService : IGoogleBooksService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;

    public GoogleBooksService(HttpClient httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _configuration = configuration;
    }

    // Calls Google Books through backend so Flutter does not expose API keys.
    public async Task<ApiResponse<List<BookDto>>> SearchAsync(string keyword, int startIndex, int maxResults, string? langRestrict, bool onlyFreeEbooks)
    {
        if (string.IsNullOrWhiteSpace(keyword))
        {
            return ApiResponse<List<BookDto>>.Fail("Keyword is required.");
        }

        var url = $"https://www.googleapis.com/books/v1/volumes?q={Uri.EscapeDataString(keyword)}&startIndex={startIndex}&maxResults={maxResults}";
        if (!string.IsNullOrWhiteSpace(langRestrict))
        {
            url += $"&langRestrict={Uri.EscapeDataString(langRestrict)}";
        }

        if (onlyFreeEbooks)
        {
            url += "&filter=free-ebooks";
        }

        url = AddApiKey(url);
        var root = await GetJsonAsync(url);
        if (root == null)
        {
            return ApiResponse<List<BookDto>>.Fail("Cannot read Google Books response.");
        }

        var books = new List<BookDto>();
        if (root.Value.TryGetProperty("items", out var items))
        {
            foreach (var item in items.EnumerateArray())
            {
                books.Add(MapGoogleBook(item));
            }
        }

        return ApiResponse<List<BookDto>>.Ok(books);
    }

    public async Task<ApiResponse<BookDto>> GetByIdAsync(string googleBookId)
    {
        var root = await GetJsonAsync(AddApiKey($"https://www.googleapis.com/books/v1/volumes/{Uri.EscapeDataString(googleBookId)}"));
        return root == null
            ? ApiResponse<BookDto>.Fail("Google book not found.")
            : ApiResponse<BookDto>.Ok(MapGoogleBook(root.Value));
    }

    private async Task<JsonElement?> GetJsonAsync(string url)
    {
        var response = await _httpClient.GetAsync(url);
        if (!response.IsSuccessStatusCode)
        {
            return null;
        }

        var json = await response.Content.ReadAsStringAsync();
        return JsonDocument.Parse(json).RootElement.Clone();
    }

    private string AddApiKey(string url)
    {
        var apiKey = _configuration["GoogleBooks:ApiKey"];
        if (string.IsNullOrWhiteSpace(apiKey))
        {
            return url;
        }

        return url.Contains('?') ? $"{url}&key={Uri.EscapeDataString(apiKey)}" : $"{url}?key={Uri.EscapeDataString(apiKey)}";
    }

    private static BookDto MapGoogleBook(JsonElement item)
    {
        var volumeInfo = item.TryGetProperty("volumeInfo", out var volume) ? volume : default;
        var accessInfo = item.TryGetProperty("accessInfo", out var access) ? access : default;

        return new BookDto
        {
            GoogleBookId = GetString(item, "id"),
            Title = GetString(volumeInfo, "title") ?? "Untitled",
            Authors = GetStringArray(volumeInfo, "authors"),
            Description = GetString(volumeInfo, "description"),
            ThumbnailUrl = GetNestedString(volumeInfo, "imageLinks", "thumbnail"),
            Categories = GetStringArray(volumeInfo, "categories"),
            PageCount = GetInt(volumeInfo, "pageCount"),
            Language = GetString(volumeInfo, "language"),
            PreviewLink = GetString(volumeInfo, "previewLink"),
            WebReaderLink = GetString(accessInfo, "webReaderLink"),
            Source = "google_books",
            PdfDownloadLink = GetNestedString(accessInfo, "pdf", "downloadLink"),
            EpubDownloadLink = GetNestedString(accessInfo, "epub", "downloadLink")
        };
    }

    private static string? GetString(JsonElement element, string propertyName)
    {
        return element.ValueKind == JsonValueKind.Object &&
               element.TryGetProperty(propertyName, out var property) &&
               property.ValueKind == JsonValueKind.String
            ? property.GetString()
            : null;
    }

    private static string? GetNestedString(JsonElement element, string objectName, string propertyName)
    {
        return element.ValueKind == JsonValueKind.Object &&
               element.TryGetProperty(objectName, out var nested)
            ? GetString(nested, propertyName)
            : null;
    }

    private static int GetInt(JsonElement element, string propertyName)
    {
        return element.ValueKind == JsonValueKind.Object &&
               element.TryGetProperty(propertyName, out var property) &&
               property.TryGetInt32(out var value)
            ? value
            : 0;
    }

    private static List<string> GetStringArray(JsonElement element, string propertyName)
    {
        if (element.ValueKind != JsonValueKind.Object ||
            !element.TryGetProperty(propertyName, out var property) ||
            property.ValueKind != JsonValueKind.Array)
        {
            return new List<string>();
        }

        return property.EnumerateArray()
            .Where(x => x.ValueKind == JsonValueKind.String)
            .Select(x => x.GetString()!)
            .ToList();
    }
}
