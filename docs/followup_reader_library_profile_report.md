# Báo cáo follow-up Reader, Library, Profile

## Tóm tắt thay đổi

- Reader giữ đọc online trong app bằng WebView và thêm nút `Lưu bookmark` dễ demo trên AppBar.
- Reader hỗ trợ lưu bookmark cho WebView, TXT, PDF/EPUB local và PDF/EPUB remote.
- PDF/EPUB vẫn mở bằng `open_filex`/ứng dụng ngoài để tránh thêm package đọc tài liệu không ổn định; UI giải thích bookmark được lưu trong Book Reader ở cấp tài liệu.
- Home Continue Reading lấy dữ liệu từ SQLite `reading_progress`, chỉ lấy progress lớn hơn 0%, sort theo `progress_percent DESC`, giới hạn 5 sách và mở Reader tại `current_page`.
- Profile Reading History chỉ hiển thị 10 progress mới nhất, tự trim bản ghi cũ và có nút xóa từng progress.
- Library Downloaded hiển thị cả sách download và sách import local TXT/PDF/EPUB có `localFilePath` hoặc `source == local_import`.
- Profile favorite card ẩn số tim/rate không thật để tránh hiển thị `0`.
- Drawer/Menu có banner `Book Reader` với subtitle `Read, save and continue your books`.

## File chính đã sửa

- Reader/bookmark: `lib/presentation/pages/reader/reader.dart`
- Home Continue: `lib/presentation/pages/home/home.dart`, `lib/presentation/pages/home/home_book_provider.dart`, `lib/core/widgets/ShareWidgetHome/wbook.dart`
- Profile reading history: `lib/presentation/pages/profile/myprofile.dart`, `lib/core/widgets/ShareWidgetProfile/historyreading.dart`
- Library Downloaded: `lib/presentation/pages/library/library_page.dart`
- Favorite UI: `lib/core/widgets/ShareWidgetProfile/wbook.dart`
- Drawer banner: `lib/presentation/pages/home/home.dart`
- DAO/SQLite: `lib/data/datasources/local/dao/reading_progress_dao.dart`
- App config/Provider: `lib/main.dart`, `lib/data/datasources/remote/api/google_books_api.dart`

## DAO/SQLite

Không đổi schema. `ReadingProgressDao` được bổ sung:

- `deleteProgress(String bookId)`
- `getTopProgress({int limit = 5, bool sortByProgressDesc = true})`
- `getRecentProgress({int limit = 10})`
- `trimProgressHistory({int maxItems = 10})`

## Hạn chế còn lại

- PDF/EPUB chưa render nội bộ trong Flutter.
- Khi PDF/EPUB mở bằng ứng dụng ngoài, Book Reader không biết trang thật bên trong app đọc ngoài, nên bookmark là bookmark cấp tài liệu với page hiện có hoặc `1`.
- Không thêm package PDF/EPUB mới để giữ Android build ổn định.

## Validation

| Lệnh | Kết quả |
| --- | --- |
| `flutter pub get` | Thành công |
| `dart format .` | Thành công |
| `flutter analyze` | No issues found |
| `flutter test` | All tests passed |
| `flutter build apk --debug` | Thành công, tạo `app-debug.apk` |

## Gợi ý ảnh minh chứng

- WebView reader có nút `Lưu bookmark`.
- Màn PDF/EPUB fallback có nút `Lưu bookmark cho tài liệu`.
- Home `Continue Reading` hiển thị 4-5 sách đang đọc.
- Profile `Reading History` tối đa 10 item và có nút xóa.
- Library `Downloaded` hiển thị sách import/download.
- Favorite trong Profile không còn số tim `0`.
- Drawer banner `Book Reader`.
