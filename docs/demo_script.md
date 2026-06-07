# Kịch bản demo đồ án Book Reader

## 1. Mở app

1. Chạy backend tại `http://localhost:5102`.
2. Chạy app Flutter trên Android emulator.
3. Màn Splash hiển thị logo, sau đó chuyển tới Login nếu chưa có session.

## 2. Đăng nhập hoặc đăng ký

1. Từ màn Login chọn `Sign in` hoặc `Sign up`.
2. Thử nhập sai email/mật khẩu để minh chứng validation.
3. Đăng nhập bằng tài khoản backend hoặc đăng ký tài khoản mới.
4. Nếu backend lỗi, app hiển thị lỗi thay vì tự tạo user giả.

## 3. Home và tìm kiếm sách

1. Vào Home qua bottom navigation.
2. Quan sát danh sách sách dạng ngang bằng `ListView`.
3. Nhập từ khóa vào ô Search.
4. Mở một sách bất kỳ để vào Book Detail.

## 4. Book Detail

1. Xem bìa, tên sách, tác giả, thể loại, số trang, mô tả.
2. Bấm biểu tượng tim để thêm/xóa Favorite local.
3. Bấm `Thêm vào tủ sách` để thêm vào library backend theo user đang đăng nhập.
4. Bấm `Đọc sách` để mở Reader.

## 5. Library và GridView

1. Chọn tab Library ở bottom navigation.
2. Xem danh sách sách đã lưu.
3. Bấm nút đổi layout trên AppBar để chuyển sang GridView.
4. Bấm nút import file để chọn `txt`, `pdf`, hoặc `epub`.
5. Mở sách từ Library.

## 6. Reader, progress, bookmark, comment

1. Nếu sách có link online, Reader mở bằng WebView.
2. Nếu file TXT local, Reader hiển thị text trong app.
3. Nếu file PDF/EPUB local, bấm `Mo bang ung dung khac`.
4. Chuyển trang để lưu reading progress vào SQLite.
5. Bấm Bookmark để lưu/xem bookmark.
6. Bấm Comment để thêm bình luận local.

## 7. News

1. Chọn tab Communicate.
2. Quan sát danh sách tin tức từ LitHub API.
3. Tìm kiếm tin tức.
4. Mở bài viết bằng trình duyệt ngoài.

## 8. Profile

1. Chọn tab Profile.
2. Xem thông tin người dùng, số sách đọc/đang đọc/download.
3. Xem Favorite và Reading History lấy từ SQLite.
4. Bấm Edit Profile, thử validation email/phone/password.
5. Lưu profile local.
6. Bấm đăng xuất để quay về Login.

## 9. Membership

1. Từ Profile bấm `Hội viên`.
2. Xem danh sách gói từ backend.
3. Chọn gói và bấm BUY NOW.

## 10. Kết luận demo

Nhấn mạnh các minh chứng môn học:

- Flutter UI nhiều màn hình.
- Navigation bằng route và bottom nav.
- ListView và GridView.
- Form validation.
- Provider state management.
- SQLite local storage.
- API/backend ASP.NET Core.
- Device features: file picker, WebView, URL launcher, open local file.
- Analyze/test/build đã kiểm tra.
