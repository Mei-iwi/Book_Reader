# Kế hoạch sửa Reader, Home, Profile và Library

## Vấn đề hiện tại

- Reader đã có lưu bookmark/progress nhưng nút lưu bookmark chưa hiển thị rõ trên AppBar.
- Đọc online đã dùng WebView trong app, nhưng chưa có thông báo rõ cho bookmark online.
- PDF/EPUB vẫn mở bằng ứng dụng ngoài; cần lưu bookmark ở cấp tài liệu và giải thích giới hạn này trong UI.
- Home Continue đang để trống, chưa lấy dữ liệu từ SQLite `reading_progress`.
- Profile đang hiển thị toàn bộ lịch sử đọc, chưa giới hạn 10 bản ghi gần nhất và chưa có nút xóa từng tiến độ.
- Library filter Downloaded chỉ dựa vào `isDownloaded`, có thể bỏ sót file import/local có `localFilePath`.
- Favorite trong Profile đang truyền `rateFavourite: 0`, làm hiển thị số tim không đúng dữ liệu thật.
- Drawer/Menu còn header đơn giản, chưa có banner demo đẹp.

## Files sẽ chỉnh

- `lib/presentation/pages/reader/reader.dart`
- `lib/presentation/pages/home/home.dart`
- `lib/presentation/pages/home/home_book_provider.dart`
- `lib/presentation/pages/profile/myprofile.dart`
- `lib/presentation/pages/library/library_page.dart`
- `lib/data/datasources/local/dao/reading_progress_dao.dart`
- `lib/core/widgets/ShareWidgetProfile/historyreading.dart`
- `lib/core/widgets/ShareWidgetProfile/wbook.dart`
- `lib/core/widgets/ShareWidgetHome/wbook.dart`
- `lib/main.dart`
- `README.md`
- `docs/final_project_completion_report.md`
- `docs/course_requirement_checklist.md`
- `docs/demo_script.md`
- `docs/final_validation_report.md`
- `docs/followup_reader_library_profile_report.md`

## Hành vi mong đợi sau khi sửa

- Reader có nút `Lưu bookmark` rõ ràng trên AppBar cho WebView, TXT, PDF/EPUB local và PDF/EPUB remote.
- Dialog danh sách bookmark vẫn hoạt động và có tooltip tiếng Việt.
- PDF/EPUB mở bằng app đọc tài liệu ngoài nhưng vẫn lưu bookmark trong Book Reader.
- Home Continue Reading lấy top 5 tiến độ đọc từ SQLite, bỏ progress 0%, sort theo `progress_percent` giảm dần và mở Reader tại `current_page`.
- Profile chỉ hiển thị 10 lịch sử đọc gần nhất, tự trim bản ghi cũ và cho phép xóa từng tiến độ bằng dialog xác nhận tiếng Việt.
- Library Downloaded hiển thị sách có `isDownloaded`, có `localFilePath`, hoặc `source == local_import`.
- Favorite trong Profile không còn hiển thị số tim `0` giả.
- Drawer có banner `Book Reader` và subtitle `Read, save and continue your books`.

## Lệnh validation

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Backend không thay đổi nên `dotnet build` là tùy chọn.

## Giới hạn còn lại

- Không thêm package đọc PDF/EPUB nội bộ để tránh rủi ro làm vỡ Android build.
- PDF/EPUB mở bằng app ngoài nên bookmark là bookmark cấp tài liệu, page lưu là `current_page` hiện có hoặc `1`, không phải trang thật bên trong app đọc ngoài.
