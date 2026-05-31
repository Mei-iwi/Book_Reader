# Book Reader

## 1. Giới thiệu dự án

Tên đề tài: **Xây dựng ứng dụng đọc sách Book Reader**.

Book Reader là ứng dụng Flutter đọc sách có các chức năng chính: đăng ký, đăng nhập, tìm kiếm sách, xem chi tiết sách, lưu tủ sách, đọc offline, lưu tiến độ đọc, bookmark, ghi chú và gói thành viên.

Kiến trúc tổng thể:

- Flutter Mobile App
- SQLite local
- ASP.NET Core Web API .NET 8
- SQL Server
- Entity Framework Core theo hướng Database First

## 2. Công nghệ sử dụng

- Flutter / Dart
- Provider
- SQLite local
- ASP.NET Core Web API .NET 8
- Entity Framework Core 9.0.0
- SQL Server / SQL Server Express
- Swagger

## 3. Cấu trúc thư mục

```text
book_reader/
├── lib/                              # Source code Flutter
│   ├── config/                       # Route, theme, cấu hình app
│   ├── core/                         # Constants, services, widget dùng chung
│   ├── data/                         # Model, datasource local/remote
│   ├── domain/                       # Entity, repository interface/usecase
│   └── presentation/                 # UI pages và Provider state
├── assets/                           # Hình ảnh, icon, font, dữ liệu mẫu
├── docs/                             # Tài liệu phân tích, thiết kế, báo cáo
├── backend/
│   └── BookReader.Api/               # ASP.NET Core Web API
│       ├── Controllers/              # API Controllers
│       ├── Data/                     # BookReaderDbContext
│       ├── Entities/                 # Entity scaffold từ SQL Server
│       ├── DTOs/                     # Request/Response DTO
│       ├── Services/                 # Xử lý nghiệp vụ
│       └── Repositories/             # Truy cập dữ liệu bằng EF Core
├── android/
├── ios/
├── web/
└── pubspec.yaml
```

## 4. Cấu hình SQL Server

Connection string mẫu:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=MEI\\SQLEXPRESS;Initial Catalog=BookReaderDb;User ID=sa;Password=123;Trust Server Certificate=True"
  }
}
```

File cấu hình backend:

```text
backend/BookReader.Api/appsettings.json
backend/BookReader.Api/appsettings.Development.json
```

Nếu máy khác không dùng SQL Server instance `MEI\SQLEXPRESS`, hãy đổi `Data Source` cho đúng môi trường local.

## 5. Tạo database BookReaderDb

Mở SQL Server Management Studio hoặc Azure Data Studio và chạy:

```sql
CREATE DATABASE BookReaderDb;
GO
```

Nếu database đã tồn tại thì không cần tạo lại.

## 6. Chạy SQL script không dùng migration

Dự án dùng hướng **Database First**, vì vậy không tạo database bằng EF Core migration.

File SQL Server full script của dự án:

```text
D:\StudyMaterials\HK6\MobileProgramming\Groups\FinalProject\BookReader_SQLServer_FullScript.sql
```

Chạy script trên database `BookReaderDb`:

```sql
USE BookReaderDb;
GO
-- Chạy nội dung file BookReader_SQLServer_FullScript.sql
```

Script này tạo bảng và seed dữ liệu mẫu cho người dùng, sách, tác giả, danh mục, tủ sách, tiến độ đọc, bookmark, ghi chú, đánh giá và gói thành viên.

## 7. Scaffold database

Chạy trong thư mục gốc repo hoặc trong `backend/BookReader.Api`:

```powershell
dotnet ef dbcontext scaffold "Data Source=MEI\SQLEXPRESS;Initial Catalog=BookReaderDb;User ID=sa;Password=123;Trust Server Certificate=True" Microsoft.EntityFrameworkCore.SqlServer --context BookReaderDbContext --context-dir Data --output-dir Entities --force --use-database-names --no-onconfiguring
```

Quy ước:

- `BookReaderDbContext` nằm trong `backend/BookReader.Api/Data`.
- Entity scaffold nằm trong `backend/BookReader.Api/Entities`.
- Không tự tạo migration nếu vẫn dùng Database First.

## 8. Tài khoản demo

Nếu `PasswordHash` trong SQL seed data là hash thật khớp với thuật toán backend, có thể thử các tài khoản mẫu trong file `BookReader_SQLServer_FullScript.sql`:

| Vai trò | Email | Mật khẩu ghi chú trong SQL |
| --- | --- | --- |
| Admin | `admin@bookreader.vn` | `123456` |
| User | `an.nguyen@example.com` | `123456` |
| User | `bao.tran@example.com` | `123456` |
| User | `chi.le@example.com` | `123456` |

Nếu đăng nhập các tài khoản seed không thành công, không hardcode mật khẩu trong Flutter hoặc backend. Hãy tạo tài khoản demo mới qua Swagger:

```text
POST /api/auth/register
```

Sau đó đăng nhập bằng:

```text
POST /api/auth/login
```

## 9. Chạy backend

Build backend:

```powershell
dotnet build backend\BookReader.Api\BookReader.Api.csproj
```

Chạy backend ở port `5102` theo `backend/BookReader.Api/Properties/launchSettings.json`:

```powershell
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj
```

## 10. Mở Swagger

Sau khi backend chạy, mở:

```text
http://localhost:5102/swagger
```

Các nhóm API chính:

- Auth: `/api/auth/register`, `/api/auth/login`, `/api/auth/me`
- Books: `/api/books`, `/api/books/{id}`
- Google Books proxy: `/api/books/google/search`, `/api/books/google/{googleBookId}`, `/api/books/import-google/{googleBookId}`
- Library: `/api/library`
- Reading progress: `/api/reading-progress/{bookId}`
- Bookmarks: `/api/bookmarks`
- Notes: `/api/notes`
- Membership: `/api/membership/packages`, `/api/membership/subscribe/{packageId}`, `/api/membership/my-plan`

## 11. Chạy Flutter

Cài package:

```powershell
flutter pub get
```

Chạy ứng dụng:

```powershell
flutter run
```

Base URL backend cho Android emulator:

```text
http://10.0.2.2:5102/api
```

Giá trị này được cấu hình tại:

```text
lib/core/constants/api_constants.dart
```

Nếu chạy trên điện thoại thật, `10.0.2.2` không dùng được. Hãy đổi base URL sang IP LAN của máy đang chạy backend, ví dụ:

```text
http://192.168.1.10:5102/api
```

Máy tính và điện thoại cần cùng mạng Wi-Fi, backend cần chạy với URL cho phép thiết bị khác truy cập.

## 12. Lưu ý Google Books

Flutter không gọi trực tiếp Google Books API. App gọi backend proxy:

```text
GET /api/books/google/search
```

Google Books có thể bị rate-limit hoặc tạm thời trả lỗi. Khi đó app đã có fallback sang dữ liệu SQL Server qua:

```text
GET /api/books?keyword=...
```

## 13. Checklist test demo

1. Bật SQL Server và kiểm tra database `BookReaderDb`.
2. Chạy file `BookReader_SQLServer_FullScript.sql` nếu database chưa có dữ liệu.
3. Chạy backend tại `http://localhost:5102`.
4. Mở Swagger tại `http://localhost:5102/swagger`.
5. Tạo tài khoản demo bằng `POST /api/auth/register` nếu tài khoản seed không đăng nhập được.
6. Test `POST /api/auth/login`.
7. Test `GET /api/books/google/search?keyword=flutter&startIndex=0&maxResults=10`.
8. Test `GET /api/books?keyword=flutter&page=1&pageSize=10`.
9. Test `GET /api/membership/packages`.
10. Chạy Flutter trên Android emulator.
11. Đăng ký, đăng nhập, tắt mở app để kiểm tra session.
12. Tìm kiếm sách và mở chi tiết sách.
13. Thêm sách vào tủ sách từ màn Book Detail.
14. Mở Library, kiểm tra load từ backend trước và fallback SQLite khi backend lỗi.
15. Mở Reader, đổi trang, kiểm tra lưu tiến độ đọc local và sync backend nếu có SQL book id.
16. Tạo bookmark, xem danh sách bookmark, xóa bookmark.
17. Mở màn Membership, kiểm tra 3 gói và thử nút subscribe.
18. Đăng xuất từ Profile và kiểm tra quay về màn đăng nhập.

## 14. Ghi chú phát triển

- Backend dùng mô hình `Controller -> Service -> Repository -> Entity`.
- API trả response theo dạng `ApiResponse<T>`.
- Flutter giữ kiến trúc `config`, `core`, `data`, `domain`, `presentation`.
- SQLite local dùng cho `offline_books`, `reading_progress`, `bookmarks`.
- Không commit output build `bin/` và `obj/`.
