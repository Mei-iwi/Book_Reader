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
- Reader có nút `Lưu bookmark` rõ trên AppBar cho WebView, TXT và PDF/EPUB mở ngoài.
- Lưu reading progress và bookmark bằng SQLite, sync backend khi có book id/user id.
- Home Continue Reading lấy top 5 sách đang đọc từ SQLite và mở lại đúng `current_page`.
- Profile giới hạn 10 lịch sử đọc gần nhất, hỗ trợ xóa từng tiến độ đọc.
- Library Downloaded hiển thị cả sách đã download và file local import có `localFilePath`.
- Bình luận local bằng SQLite.
- Favorite và reading history trong Profile; favorite card không hiển thị số tim giả.
- Drawer/Menu có banner `Book Reader`.
- Tin tức LitHub API và mở URL ngoài.
- Membership packages từ backend.

## Cách chạy project

```powershell
flutter pub get
```

Base URL backend và API key của app được tách riêng tại:

```text
lib/config/env.dart
```

Trong file này chỉ cần đổi:

```dart
static const String backendMode = 'realDeviceUsb';
```

Các mode có sẵn:

| Mode | Khi nào dùng | URL |
| --- | --- | --- |
| `realDeviceUsb` | Điện thoại thật cắm cáp USB | `http://127.0.0.1:5102/api` |
| `androidEmulator` | Máy ảo Android Studio | `http://10.0.2.2:5102/api` |
| `realDeviceLan` | Điện thoại thật qua Wi-Fi | Sửa `realDeviceLanBaseUrl` thành IP LAN của máy tính |

Mặc định project đang để `realDeviceUsb`.

### Chạy trên điện thoại thật bằng USB

Trường hợp này dùng khi cắm điện thoại thật bằng cáp USB. App sẽ gọi:

```text
http://127.0.0.1:5102/api
```

ADB reverse sẽ chuyển `127.0.0.1:5102` trên điện thoại về backend đang chạy trên máy tính.

**Bước 1: chỉnh config Flutter**

Trong `lib/config/env.dart`, để:

```dart
static const String backendMode = 'realDeviceUsb';
```

**Bước 2: terminal 1 chạy backend**

Mở terminal tại thư mục project và chạy:

```powershell
flutter pub get
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj
```

Giữ terminal này mở. Nếu backend chạy đúng sẽ thấy Swagger tại:

```text
http://localhost:5102/swagger
```

**Bước 3: terminal 2 kiểm tra điện thoại và reverse port**

Mở terminal thứ 2 tại thư mục project và chạy:

```powershell
adb devices
adb reverse tcp:5102 tcp:5102
```

`adb devices` phải hiện thiết bị ở trạng thái `device`.

**Bước 4: chạy app lên điện thoại**

Nếu chạy bằng Flutter:

```powershell
flutter run
```

Nếu muốn build APK rồi cài:

```powershell
flutter build apk --debug
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

### Chạy trên máy ảo Android

Trường hợp này dùng Android Emulator của Android Studio. App sẽ gọi:

```text
http://10.0.2.2:5102/api
```

`10.0.2.2` là địa chỉ đặc biệt để máy ảo gọi localhost của máy tính.

**Bước 1: chỉnh config Flutter**

Đổi trong `lib/config/env.dart`:

```dart
static const String backendMode = 'androidEmulator';
```

**Bước 2: terminal 1 chạy backend**

```powershell
flutter pub get
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj
```

Giữ terminal này mở.

**Bước 3: mở máy ảo và chạy app**

Kiểm tra thiết bị:

```powershell
flutter devices
```

Chạy app:

```powershell
flutter run
```

Hoặc build/cài APK nếu cần:

```powershell
flutter build apk --debug
flutter install
```

Không cần chạy `adb reverse` khi dùng máy ảo Android nếu đã để `backendMode = 'androidEmulator'`.

### Chạy trên điện thoại thật qua Wi-Fi/LAN

Đổi IP trong file config:

```dart
static const String realDeviceLanBaseUrl = 'http://192.168.1.15:5102/api';
static const String backendMode = 'realDeviceLan';
```

Thay `192.168.1.15` bằng IP LAN của máy đang chạy backend.

Lệnh xem IP LAN trên Windows:

```powershell
ipconfig
```

Tìm dòng `IPv4 Address`, ví dụ `192.168.1.15`.

Khi chạy qua Wi-Fi/LAN:

```powershell
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj
flutter run
```

Điện thoại và máy tính phải cùng Wi-Fi. Nếu vẫn không vào API, kiểm tra Windows Firewall cho port `5102`.

### Override nhanh không cần sửa file

Có thể chạy bằng `--dart-define`:

```powershell
flutter run --dart-define=BACKEND_BASE_URL=http://10.0.2.2:5102/api
```

Lưu ý: sau khi đổi mode/base URL, cần hot restart hoặc build/chạy lại app.

Google Books API key cũng đặt trong `lib/config/env.dart`:

```dart
static const String googleBooksApiKey = String.fromEnvironment(
  'GOOGLE_BOOKS_API_KEY',
  defaultValue: 'your_google_books_api_key',
);
```

Ví dụ build APK cho điện thoại thật USB bằng override:

```powershell
adb reverse tcp:5102 tcp:5102
flutter build apk --debug --dart-define=BACKEND_BASE_URL=http://127.0.0.1:5102/api
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

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

### Lỗi port 5102 đang được dùng

Nếu chạy backend gặp lỗi:

```text
Failed to bind to address http://127.0.0.1:5102: address already in use
```

nghĩa là backend cũ vẫn đang chạy. Chỉ cần dùng một trong hai cách:

1. Đóng terminal đang chạy backend cũ.
2. Hoặc tìm và dừng process `dotnet` của `BookReader.Api`:

```powershell
Get-CimInstance Win32_Process -Filter "name = 'dotnet.exe'" |
  Where-Object { $_.CommandLine -like '*BookReader.Api.csproj*' } |
  Select-Object ProcessId, CommandLine

Stop-Process -Id <ProcessId> -Force
```

Sau đó chạy lại:

```powershell
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj
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
- `docs/followup_reader_library_profile_plan.md`
- `docs/followup_reader_library_profile_report.md`

## Hạn chế còn lại

- Firebase chưa chạy thật vì thiếu cấu hình `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`.
- PDF/EPUB hiện mở bằng app ngoài, chưa render nội bộ trong Flutter; bookmark PDF/EPUB là bookmark cấp tài liệu.
- Một số file/provider cũ vẫn tồn tại để tránh rename/delete nhiều trong giai đoạn hoàn thiện.
- Một số text cũ trong source có thể cần chuẩn hóa encoding nếu tiếp tục phát triển.
