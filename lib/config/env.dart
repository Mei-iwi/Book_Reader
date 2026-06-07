class Env {
  Env._();

  // Doi backendMode o day khi doi moi truong chay app.
  // Gia tri hop le:
  // - realDeviceUsb: dien thoai that cam USB, chay adb reverse tcp:5102 tcp:5102
  // - androidEmulator: may ao Android Studio, dung 10.0.2.2
  // - realDeviceLan: dien thoai that qua Wi-Fi, sua realDeviceLanBaseUrl ben duoi
  static const String backendMode = 'realDeviceUsb';

  // Neu can override nhanh khi run/build:
  // flutter run --dart-define=BACKEND_BASE_URL=http://10.0.2.2:5102/api
  static const String backendBaseUrlOverride = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: '',
  );

  // Dung khi backendMode = realDeviceLan.
  // Thay IP nay bang IPv4 LAN cua may tinh dang chay backend.
  static const String realDeviceLanBaseUrl = 'http://192.168.1.15:5102/api';

  // Co the override bang:
  // flutter run --dart-define=GOOGLE_BOOKS_API_KEY=your_key
  static const String googleBooksApiKey = String.fromEnvironment(
    'GOOGLE_BOOKS_API_KEY',
  );
}
