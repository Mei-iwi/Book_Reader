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
- Reader hỗ trợ sách full text từ Gutendex/Project Gutenberg: tải `text/plain`, cache thành `.txt`, chia trang trong app và dùng nút previous/next.
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

Nếu cần Google Books API key, truyền bằng `--dart-define` thay vì commit file env local:

```powershell
flutter run --dart-define=GOOGLE_BOOKS_API_KEY=your_key_here
```

Base URL backend của Flutter nằm tại:

```text
lib/config/backend_environment.dart
```

Các mode có sẵn:

```text
BackendRunTarget.emulator    -> http://10.0.2.2:5102/api
BackendRunTarget.physicalUsb -> http://127.0.0.1:5102/api
BackendRunTarget.physicalLan -> http://<IP-LAN>:5102/api
```

Nếu chạy trên điện thoại thật qua USB, chạy thêm:

```powershell
adb reverse tcp:5102 tcp:5102
```

Nếu chạy qua Wi-Fi/LAN, đổi `physicalLanHost` thành IP của máy chạy backend và chạy backend bằng profile `lan`.

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

Chạy backend cho điện thoại thật qua Wi-Fi/LAN:

```powershell
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj --launch-profile lan
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
- PDF remote thử render bằng WebView trong app; PDF/EPUB local vẫn mở bằng app ngoài.
- Một số file/provider cũ vẫn tồn tại để tránh rename/delete nhiều trong giai đoạn hoàn thiện.
- Một số text cũ trong source có thể cần chuẩn hóa encoding nếu tiếp tục phát triển.

## Ghi chú kiểm tra mobile runtime 2026-06-08

Phần này chỉ ghi lại kết quả kiểm tra cuối phiên, không sửa code cũ.

### Kết quả đã chạy

```powershell
flutter analyze
flutter test
flutter build apk --debug --dart-define-from-file=firebase_env.json
dotnet build backend\BookReader.Api\BookReader.Api.csproj
adb devices
flutter devices
```

Kết quả:

- `flutter analyze`: No issues found.
- `flutter test`: All tests passed.
- `flutter build apk --debug --dart-define-from-file=firebase_env.json`: build thành công APK tại `build\app\outputs\flutter-apk\app-debug.apk`.
- `dotnet build backend\BookReader.Api\BookReader.Api.csproj`: build thành công, 0 warning, 0 error.
- `adb devices`: chưa thấy điện thoại Android được kết nối ở thời điểm kiểm tra, nên chưa thể tự động install/launch/logcat app trên máy thật.
- `flutter devices`: chỉ thấy Windows desktop, Chrome, Edge; không thấy Android device.

### Checklist chạy như app mobile thật

1. Cắm điện thoại Android, bật Developer options và USB debugging.
2. Kiểm tra máy đã nhận ADB:

```powershell
adb devices
```

Nếu chưa thấy device, đổi cáp/cổng USB hoặc chọn lại chế độ USB trên điện thoại.

3. Chạy backend trên máy tính:

```powershell
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj
```

4. Nếu chạy điện thoại thật qua USB, mở reverse port để app gọi backend local:

```powershell
adb reverse tcp:5102 tcp:5102
```

5. Chạy app với Firebase env:

```powershell
flutter run --dart-define-from-file=firebase_env.json
```

6. Nếu app cũ/cache gây lỗi, gỡ app trước rồi chạy lại:

```powershell
adb uninstall com.example.book_reader
flutter run --dart-define-from-file=firebase_env.json
```

### Firebase/Google Sign-In cần đúng

- Android package trong Firebase phải là `com.example.book_reader`.
- Google provider trong Firebase Authentication phải được bật.
- `firebase_env.json` phải có `FIREBASE_PROJECT_ID`, `FIREBASE_WEB_API_KEY`, `FIREBASE_GOOGLE_CLIENT_ID`, `FIREBASE_GOOGLE_SERVER_CLIENT_ID`.
- Debug SHA cần khai báo trong Firebase Android app:

```text
SHA-1: 53:41:95:AA:E1:CC:AA:EE:80:9D:AB:B0:E1:86:BA:DF:18:64:AF:72
SHA-256: 39:17:3A:8C:CD:16:74:44:6A:39:B7:12:06:76:8F:86:83:B7:9F:67:29:54:A7:15:27:28:ED:F4:0E:FF:82:AD
```

Ghi chú: app đang dùng Google Sign-In picker kiểu cũ (`google_sign_in` 6.3.0) để tránh lỗi màn Credential Manager trắng trên một số máy Android/Vivo.

### Luồng demo nên thử khi có điện thoại

1. Mở app từ splash vào login.
2. Đăng nhập Google, xác nhận vào được Home.
3. Tìm sách bằng ô search trên Home.
4. Mở detail một sách Google/Gutendex.
5. Bấm lưu/download vào Library.
6. Mở Library và đọc lại sách đã lưu.
7. Kiểm tra Profile/history/favorite nếu có dữ liệu.

Nếu Home không tải sách từ backend, kiểm tra backend đang chạy ở `http://localhost:5102` và đã chạy `adb reverse tcp:5102 tcp:5102`.

## Ghi chú kiểm tra google-services và backend 2026-06-08

### Firebase Android config

File `android/app/google-services.json` hiện thuộc Firebase project:

```text
project_id: book-reader-8c22c
package_name: com.example.book_reader
```

`firebase_env.json` đã được chỉnh để khớp với project/API key/Web OAuth client trong file `google-services.json`.

Điểm cần chú ý: `google-services.json` hiện chỉ thấy OAuth client loại Web (`client_type: 3`), chưa thấy Android OAuth client (`client_type: 1`). Nếu đăng nhập Google vẫn báo:

```text
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10:)
```

thì vào Firebase Console -> Project settings -> app Android `com.example.book_reader` -> thêm fingerprint debug:

```text
SHA-1: 53:41:95:AA:E1:CC:AA:EE:80:9D:AB:B0:E1:86:BA:DF:18:64:AF:72
SHA-256: 39:17:3A:8C:CD:16:74:44:6A:39:B7:12:06:76:8F:86:83:B7:9F:67:29:54:A7:15:27:28:ED:F4:0E:FF:82:AD
```

Sau đó tải lại `google-services.json` mới và thay vào `android/app/google-services.json`.

### Backend/API

Đã test `GET http://localhost:5102/api/books` trả `200 OK` và có dữ liệu sách. Điện thoại thật qua USB đang cần reverse port:

```powershell
adb reverse tcp:5102 tcp:5102
```

Kiểm tra reverse hiện tại:

```powershell
adb reverse --list
```

Kết quả mong muốn có dòng:

```text
UsbFfs tcp:5102 tcp:5102
```

Nếu backend không lên hoặc Home không tải sách, kiểm tra lại `backend/BookReader.Api/appsettings.json` và `backend/BookReader.Api/appsettings.Development.json` cho đúng SQL Server local, rồi chạy lại:

```powershell
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj --launch-profile http
```

Nếu lệnh trên báo `Failed to bind to address http://127.0.0.1:5102: address already in use`, nghĩa là backend đang chạy sẵn trên port `5102`; không cần chạy thêm, hoặc dừng process đó rồi chạy lại.

## Ghi chú fix load sách backend 2026-06-08

App đã có đường gọi trực tiếp `GET /api/books` từ backend và Home sẽ hiện section `Backend Books` lấy dữ liệu SQL Server trước, không phải chờ Google Books. Search cũng ưu tiên kết quả từ backend trước, sau đó mới merge thêm Google Books/Gutendex.

Khi chạy trên điện thoại thật qua USB, cần đủ 2 thứ:

```powershell
dotnet run --project backend\BookReader.Api\BookReader.Api.csproj --launch-profile http
adb reverse tcp:5102 tcp:5102
```

Đã kiểm tra:

- `GET http://localhost:5102/api/books`: `200 OK`, có dữ liệu sách.
- `flutter analyze`: No issues found.
- `flutter test`: All tests passed.
- `flutter build apk --debug --dart-define-from-file=firebase_env.json`: build thành công.
