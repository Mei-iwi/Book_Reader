# Hướng dẫn tích hợp Firebase an toàn

## Trạng thái hiện tại

Project hiện chưa có cấu hình Firebase runtime:

- Không thấy `lib/firebase_options.dart`.
- Không thấy `android/app/google-services.json`.
- Không thấy `ios/Runner/GoogleService-Info.plist`.
- `pubspec.yaml` chưa có `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`.

Vì vậy không nên thêm `Firebase.initializeApp()` ngay lúc này, vì app sẽ dễ lỗi build/runtime khi thiếu cấu hình.

## Hướng tích hợp đề xuất

Nếu giảng viên yêu cầu minh chứng Firebase, nên chọn một vai trò nhỏ, không phá backend hiện tại:

| Phương án | Mức rủi ro | Ghi chú |
| --- | --- | --- |
| Firebase Storage cho ảnh đại diện | Thấp | Giữ backend auth hiện tại, chỉ upload avatar nếu có config |
| Cloud Firestore cho ghi chú đọc sách demo | Trung bình | Cần đồng bộ user id rõ ràng |
| Firebase Auth thay backend auth | Cao | Không khuyến nghị vì project đã có ASP.NET Core Auth |

## Các bước cấu hình sau này

1. Tạo Firebase project trên Firebase Console.
2. Cài FlutterFire CLI nếu chưa có.
3. Chạy:

```powershell
flutterfire configure
```

4. Thêm dependency phù hợp:

```powershell
flutter pub add firebase_core
flutter pub add firebase_storage
```

5. Chỉ khi đã có `firebase_options.dart`, khởi tạo trong `lib/main.dart`:

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

6. Gắn feature nhỏ, ví dụ upload avatar trong `EditProfilePage`, lưu URL vào `ProfileDao` hoặc backend.

## Kết luận

Ở trạng thái nộp hiện tại, project đã có backend API, SQLite, file picker, WebView và URL launcher. Firebase được ghi là chưa tích hợp do thiếu cấu hình an toàn, tránh làm hỏng luồng đăng nhập/backend hiện có.
