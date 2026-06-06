# Checklist yêu cầu môn Mobile Programming

| Requirement | Status | Evidence file path | Notes |
| --- | --- | --- | --- |
| Ứng dụng Flutter giải quyết vấn đề thực tế | Đạt | `lib/main.dart`, `lib/presentation/pages/home/home.dart` | App đọc sách/tủ sách/tin tức/thành viên |
| UI Flutter rõ ràng | Đạt | `lib/presentation/pages/**/*.dart` | Có Scaffold, AppBar, BottomNavigationBar, Card, Form |
| Nhiều màn hình và điều hướng | Đạt | `lib/config/routes.dart`, `lib/presentation/pages/home/homescreen.dart` | Splash, Auth, Home, Library, Detail, Reader, News, Profile |
| StatelessWidget và StatefulWidget | Đạt | `lib/app.dart`, `lib/presentation/pages/**` | `Application` là StatelessWidget; nhiều page là StatefulWidget |
| ListView | Đạt | `lib/presentation/pages/home/home.dart`, `lib/presentation/pages/library/library_page.dart`, `lib/presentation/pages/communicate/news_page.dart` | Danh sách sách/tin tức |
| GridView trong flow thật | Đạt | `lib/presentation/pages/library/library_page.dart` | Library có nút chuyển List/Grid |
| User input forms | Đạt | `sign_in.dart`, `sign_up.dart`, `editprofile.dart`, `comments.dart` | Auth, profile, comment |
| Validation/constraints | Đạt | `lib/core/utils/validators.dart`, auth/profile/comment pages | Email, phone, password, max length |
| Models/classes | Đạt | `lib/domain/entities/*.dart`, `lib/data/models/*.dart` | Book, User, News, MembershipPackage |
| SQLite/local storage | Đạt | `lib/data/datasources/local/sqlite/app_database.dart`, `dao/*.dart` | Offline books, progress, bookmarks, comments, profile, favorites; Continue/Profile đọc progress từ SQLite |
| API interaction | Đạt | `lib/core/services/http/api_client.dart`, `lib/data/datasources/remote/api/*.dart` | Backend API và LitHub API |
| Firebase | Chưa tích hợp runtime | `docs/firebase_setup_guide.md` | Thiếu config Firebase, đã tài liệu hóa cách tích hợp an toàn |
| Device/multimedia feature | Đạt | `library_page.dart`, `reader.dart`, `news_page.dart` | File picker, local file, WebView trong app, URL launcher fallback, open_filex cho PDF/EPUB |
| CRUD operations | Đạt một phần | `dao/*.dart`, `reader.dart`, `comments.dart`, `book_detail_page.dart`, `myprofile.dart` | Local add/read/update progress, bookmark/favorite/comment; Profile có xóa progress; comment chưa có update UI |
| Loading/empty/success/error states | Đạt | `home.dart`, `library_page.dart`, `news_page.dart`, `membership_package_page.dart` | Có loading, empty, snackbar/error text |
| Code organization | Đạt | `lib/config`, `lib/core`, `lib/data`, `lib/domain`, `lib/presentation` | Vẫn còn provider cũ chưa dùng nhưng flow chính rõ hơn |
| Analyze/test/build | Đạt | `docs/final_validation_report.md` | Analyze sạch, test pass, APK debug build được |
