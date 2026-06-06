# Kế hoạch hoàn thiện đồ án Book Reader

## 1. Trạng thái hiện tại

| Hạng mục | Hiện trạng phát hiện | Bằng chứng |
| --- | --- | --- |
| Kiến trúc | Có cấu trúc `config/core/data/domain/presentation`, backend ASP.NET Core riêng | `lib/`, `backend/BookReader.Api/`, `docs/current_project_architecture_dossier.md` |
| State management | Dùng Provider/ChangeNotifier nhưng có provider trùng và `BookProvider` chưa đăng ký | `lib/main.dart`, `lib/presentation/state/book_provider.dart`, `lib/presentation/pages/home/home_book_provider.dart`, `lib/presentation/state/home_book_provider.dart` |
| Auth | Có login/register/session nhưng đang fallback mock khi API lỗi | `lib/presentation/state/auth_provider.dart` |
| User id | Một số luồng dùng `userId: 1` | `lib/presentation/state/library_provider.dart`, `lib/presentation/state/membership_provider.dart`, `lib/presentation/pages/reader/reader.dart` |
| Navigation | Bottom nav hiện dùng `CategoryPage` ở tab Library; Library thật phải vào qua category item | `lib/presentation/pages/home/homescreen.dart`, `lib/presentation/state/category/category_page.dart` |
| GridView | Có trong `lib/presentation/test.dart` nhưng chưa thuộc flow chính | `lib/presentation/test.dart` |
| SQLite | Có database và DAO cho offline books, progress, bookmarks, comments, profile, favorites | `lib/data/datasources/local/sqlite/app_database.dart`, `lib/data/datasources/local/dao/*.dart` |
| Device feature | Có file picker, WebView, URL launcher, local file handling; `open_filex` đã có dependency nhưng chưa dùng | `pubspec.yaml`, `library_page.dart`, `reader.dart`, `news_page.dart` |
| Firebase | Không có config/dependency an toàn để khởi tạo | Không thấy `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist` |
| Validation | Có nhưng còn đơn giản | `sign_in.dart`, `sign_up.dart`, `editprofile.dart`, `comments.dart` |
| Validation/build | Flutter/Dart từng timeout; cần chạy lại và ghi báo cáo | `docs/current_project_architecture_dossier.md` |

## 2. Chức năng thiếu hoặc cần hoàn thiện

| Ưu tiên | Thiếu sót | Cách hoàn thiện an toàn |
| --- | --- | --- |
| Critical | ProviderNotFound cho `BookProvider` | Đăng ký `BookProvider(SearchBooks(bookRepository))` trong `lib/main.dart` |
| Critical | Auth fake khi backend lỗi | Gỡ mock fallback, lưu `errorMessage`, trả `false` |
| High | Hardcode user id | Cho `LibraryProvider`/`MembershipProvider` nhận user id từ UI/AuthProvider; `Reader` nhận `userId` nullable |
| High | Navigation tab Library khó demo | Đổi tab Library mở `LibraryPage` trực tiếp; giữ `CategoryPage` nếu cần dùng sau |
| High | GridView chưa ở flow chính | Thêm chế độ grid/list trong `LibraryPage` bằng dữ liệu sách thật |
| High | Reader chưa xử lý PDF/EPUB tốt | Dùng `open_filex` để mở PDF/EPUB bằng app ngoài, kèm thông báo rõ |
| Medium | Form validation yếu | Thêm helper validator nhỏ trong `lib/core/utils/validators.dart` và dùng cho auth/profile/comment |
| Medium | Reading progress chưa load khi mở reader | Reader đọc progress local trong `initState` và đặt trang hiện tại |
| Medium | Firebase missing | Tạo `docs/firebase_setup_guide.md`, không thêm runtime Firebase |
| Medium | Docs nộp bài thiếu | Cập nhật README và tạo final reports/checklist/demo script/validation report |

## 3. File dự kiến chỉnh sửa

| Nhóm | File | Rủi ro |
| --- | --- | --- |
| State/Auth | `lib/main.dart`, `lib/presentation/state/auth_provider.dart`, `lib/presentation/state/library_provider.dart`, `lib/presentation/state/membership_provider.dart` | Trung bình |
| Navigation/UI | `lib/presentation/pages/home/homescreen.dart`, `lib/presentation/pages/library/library_page.dart`, `lib/presentation/pages/book_detail/book_detail_page.dart`, `lib/presentation/pages/membership/membership_package_page.dart`, `lib/presentation/pages/reader/reader.dart` | Trung bình |
| Validation | `lib/core/utils/validators.dart`, `sign_in.dart`, `sign_up.dart`, `editprofile.dart`, `comments.dart` | Thấp |
| SQLite/local | `lib/data/datasources/local/dao/comment_dao.dart`, `reader.dart` | Thấp |
| Device feature | `reader.dart` dùng `open_filex` | Thấp |
| Docs/tests | `README.md`, `docs/*.md`, `test/*` nếu thêm được | Thấp |

## 4. Lệnh kiểm tra sẽ chạy

| Lệnh | Mục đích | Ghi chú |
| --- | --- | --- |
| `flutter pub get` | Đồng bộ package | Nếu timeout/network lỗi, ghi vào validation report |
| `dart format .` | Format Dart | Có thể sửa format code |
| `flutter analyze` | Kiểm tra lỗi phân tích | Sửa lỗi thật, không tắt lint toàn cục |
| `flutter test` | Chạy test | Sửa test nếu app entry thay đổi |
| `flutter build apk --debug` | Kiểm tra build Android debug | Nếu quá chậm/không hỗ trợ, ghi rõ |
| `dotnet restore backend/BookReader.Api/BookReader.Api.csproj` | Restore backend | Nếu dotnet có sẵn |
| `dotnet build backend/BookReader.Api/BookReader.Api.csproj` | Build backend | Không sửa schema nặng |

## 5. Nguyên tắc giới hạn rủi ro

- Không đổi tên hàng loạt file/folder/class.
- Không thêm Firebase runtime khi thiếu config.
- Không thay đổi schema SQLite nếu chưa cần migration.
- Không sửa các file `backend/BookReader.Api/obj/**` đang dirty sẵn.
- Ưu tiên build/demo flow: Splash -> Login/Register -> Home -> Detail -> Library Grid/List -> Reader -> Comment/Bookmark/Profile/News/Membership.
