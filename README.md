# Book Reader

Book Reader là đồ án Flutter cho môn Mobile Programming. Ứng dụng hỗ trợ tìm kiếm sách, xem chi tiết, lưu vào thư viện, đọc online/offline, lưu tiến độ đọc, bookmark, bình luận, tin tức sách, hồ sơ người dùng và gói thành viên.

## Công nghệ

| Nhóm | Công nghệ |
| --- | --- |
| Mobile app | Flutter, Dart |
| State management | Provider, ChangeNotifier |
| Local storage | SQLite `sqflite`, file local bằng `path_provider` |
| API | HTTP client, ASP.NET Core Web API |
| Backend | .NET 8, Entity Framework Core, SQL Server |
| Device/multimedia | File picker, WebView, URL launcher, open local file |
| Test/lint | flutter_test, flutter_lints |

## Kiến trúc

```text
lib/
├── config/        # routes, theme
├── core/          # constants, services, validators, shared widgets
├── data/          # models, local SQLite DAO, remote API datasource
├── domain/        # entities, repositories, usecases
└── presentation/  # screens and Provider state

backend/BookReader.Api/
├── Controllers/
├── Services/
├── Repositories/
├── Data/
└── Entities/
```

Luồng tổng thể:

```text
Flutter UI -> Provider -> Repository -> API/SQLite -> ASP.NET Core -> SQL Server
```

## Tính năng chính

- Splash và session local.
- Đăng nhập/đăng ký bằng backend API.
- Validation email, số điện thoại, mật khẩu, profile, comment.
- Home hiển thị danh sách sách bằng ListView.
- Tìm kiếm sách qua backend Google Books proxy hoặc SQL fallback.
- Xem chi tiết sách.
- Thêm sách vào thư viện theo user đăng nhập.
- Thư viện có ListView và GridView thật trong app flow.
- Import file `txt`, `pdf`, `epub`.
- Reader hỗ trợ WebView, TXT local, mở PDF/EPUB bằng ứng dụng ngoài.
- Lưu reading progress và bookmark bằng SQLite, sync backend khi có book id/user id.
- Bình luận local bằng SQLite.
- Favorite và reading history trong Profile.
- Tin tức LitHub API và mở URL ngoài.
- Membership packages từ backend.

## Cài đặt Flutter

```powershell
flutter pub get
flutter run
```

Base URL backend cho Android emulator nằm tại:

```text
lib/core/constants/api_constants.dart
```

Mặc định:

```text
http://10.0.2.2:5102/api
```

Nếu chạy trên điện thoại thật, đổi `10.0.2.2` thành IP LAN của máy chạy backend.

## Cài đặt backend

Backend nằm trong:

```text
backend/BookReader.Api
```

Restore/build:

```powershell
dotnet restore backend\BookReader.Api\BookReader.Api.csproj
dotnet build backend\BookReader.Api\BookReader.Api.csproj
```

Chạy backend:

```powershell
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj
```

Swagger:

```text
http://localhost:5102/swagger
```

## Database

Backend dùng SQL Server với connection string trong:

```text
backend/BookReader.Api/appsettings.json
```

Database mặc định:

```text
BookReaderDb
```

Nếu máy không dùng instance `MEI\SQLEXPRESS`, cần đổi `Data Source` cho phù hợp.

## Kiểm tra cuối

Các lệnh đã chạy:

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
dotnet restore backend\BookReader.Api\BookReader.Api.csproj
dotnet build backend\BookReader.Api\BookReader.Api.csproj
```

Kết quả:

- `flutter analyze`: No issues found.
- `flutter test`: All tests passed.
- `flutter build apk --debug`: tạo `build/app/outputs/flutter-apk/app-debug.apk`.
- `dotnet build`: 0 warning, 0 error.

Chi tiết xem `docs/final_validation_report.md`.

## Checklist môn học

| Yêu cầu | Trạng thái |
| --- | --- |
| Flutter UI nhiều màn hình | Đạt |
| Navigation | Đạt |
| ListView | Đạt |
| GridView trong flow thật | Đạt |
| Form/input validation | Đạt |
| Models/classes | Đạt |
| SQLite/local storage | Đạt |
| API/backend | Đạt |
| Device/multimedia feature | Đạt |
| CRUD | Đạt một phần |
| Firebase | Chưa tích hợp runtime, có hướng dẫn setup |
| Analyze/test/build | Đạt |

## Tài liệu nộp bài

- `docs/current_project_architecture_dossier.md`
- `docs/final_completion_plan.md`
- `docs/final_project_completion_report.md`
- `docs/course_requirement_checklist.md`
- `docs/demo_script.md`
- `docs/final_validation_report.md`
- `docs/firebase_setup_guide.md`

## Hạn chế còn lại

- Firebase chưa chạy thật vì thiếu cấu hình `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`.
- PDF/EPUB hiện mở bằng app ngoài, chưa render nội bộ trong Flutter.
- Một số file/provider cũ vẫn tồn tại để tránh rename/delete nhiều trong giai đoạn hoàn thiện.
- Một số text cũ trong source có thể cần chuẩn hóa encoding nếu tiếp tục phát triển.
