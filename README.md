# Book Reader

## 1. Giới Thiệu Dự Án

Tên đề tài: **Xây dựng ứng dụng đọc sách Book Reader**.

Book Reader là ứng dụng đọc sách xây dựng bằng Flutter. Ứng dụng có các chức năng chính: đăng ký, đăng nhập, tìm kiếm sách, xem chi tiết sách, lưu tủ sách, đọc offline, lưu tiến độ đọc, bookmark, ghi chú và gói thành viên.

Kiến trúc tổng thể:

- Flutter Mobile App
- SQLite local
- ASP.NET Core Web API .NET 8
- SQL Server
- Entity Framework Core theo hướng Database First

## 2. Công Nghệ Sử Dụng

- Flutter / Dart
- Provider
- SQLite local
- ASP.NET Core Web API .NET 8
- Entity Framework Core 9.0.0
- SQL Server / SQL Server Express
- Swagger

## 3. Cấu Trúc Thư Mục

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

## 4. Cấu Hình SQL Server

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

## 5. Tạo Database `BookReaderDb`

Mở SQL Server Management Studio hoặc Azure Data Studio và chạy:

```sql
CREATE DATABASE BookReaderDb;
GO
```

Nếu database đã tồn tại thì không cần tạo lại.

## 6. Chạy SQL Script Không Dùng Migration

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

## 7. Scaffold Database

Chạy trong thư mục gốc repo hoặc trong `backend/BookReader.Api`:

```powershell
dotnet ef dbcontext scaffold "Data Source=MEI\SQLEXPRESS;Initial Catalog=BookReaderDb;User ID=sa;Password=123;Trust Server Certificate=True" Microsoft.EntityFrameworkCore.SqlServer --context BookReaderDbContext --context-dir Data --output-dir Entities --force --use-database-names --no-onconfiguring
```

Quy ước:

- `BookReaderDbContext` nằm trong `backend/BookReader.Api/Data`.
- Entity scaffold nằm trong `backend/BookReader.Api/Entities`.
- Không tự tạo migration nếu vẫn dùng Database First.

## 8. Tài Khoản Mẫu

Các tài khoản dưới đây được lấy từ seed data trong file `BookReader_SQLServer_FullScript.sql`, phần `INSERT INTO dbo.AppUsers`.

Comment trong file SQL ghi rõ các giá trị `PasswordHash` mẫu tương ứng với mật khẩu: `123456`.

| Vai trò | Họ tên | Email | Mật khẩu |
| --- | --- | --- | --- |
| Admin | Quản trị viên Book Reader | `admin@bookreader.vn` | `123456` |
| User | Nguyễn Minh An | `an.nguyen@example.com` | `123456` |
| User | Trần Gia Bảo | `bao.tran@example.com` | `123456` |
| User | Lê Phương Chi | `chi.le@example.com` | `123456` |

Ghi chú: nếu backend thay đổi thuật toán hash mật khẩu, hãy tạo lại tài khoản qua API:

```text
POST /api/auth/register
```

## 9. Chạy Backend

Build backend:

```powershell
dotnet build backend\BookReader.Api\BookReader.Api.csproj
```

Chạy backend ở port `5000`:

```powershell
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj --urls "http://localhost:5000"
```

## 10. Mở Swagger

Sau khi backend chạy, mở:

```text
http://localhost:5000/swagger
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
http://10.0.2.2:5000/api
```

Giá trị này được cấu hình tại:

```text
lib/core/constants/api_constants.dart
```

## 12. Checklist Test Demo

1. Bật SQL Server và kiểm tra database `BookReaderDb`.
2. Chạy file `BookReader_SQLServer_FullScript.sql`.
3. Chạy backend tại `http://localhost:5000`.
4. Mở Swagger tại `http://localhost:5000/swagger`.
5. Test `POST /api/auth/login` với `admin@bookreader.vn` / `123456`.
6. Test `POST /api/auth/login` với `an.nguyen@example.com` / `123456`.
7. Test `GET /api/books/google/search?keyword=flutter&startIndex=0&maxResults=10`.
8. Test `POST /api/books/import-google/{googleBookId}`.
9. Chạy Flutter trên Android emulator.
10. Đăng nhập bằng tài khoản mẫu hoặc đăng ký tài khoản mới.
11. Tìm kiếm sách từ Flutter và kiểm tra dữ liệu đi qua backend proxy.
12. Lưu sách offline và kiểm tra thư viện SQLite local.
13. Mở màn đọc sách, đổi trang và kiểm tra lưu tiến độ đọc.
14. Lưu bookmark và kiểm tra app không crash nếu backend sync lỗi.
15. Mở màn gói thành viên và kiểm tra danh sách gói từ `/api/membership/packages`.

## 13. Ghi Chú Phát Triển

- Backend dùng mô hình `Controller -> Service -> Repository -> Entity`.
- API trả response theo dạng `ApiResponse<T>`.
- Flutter giữ kiến trúc `config`, `core`, `data`, `domain`, `presentation`.
- SQLite local dùng cho `offline_books`, `reading_progress`, `bookmarks`.
- Flutter không gọi trực tiếp Google Books API; backend proxy chịu trách nhiệm gọi Google Books.
