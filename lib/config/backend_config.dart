import 'package:book_reader/config/env.dart';

enum BackendMode { realDeviceUsb, androidEmulator, realDeviceLan }

class BackendConfig {
  BackendConfig._();

  static BackendMode get activeMode {
    switch (Env.backendMode) {
      case 'androidEmulator':
        return BackendMode.androidEmulator;
      case 'realDeviceLan':
        return BackendMode.realDeviceLan;
      case 'realDeviceUsb':
      default:
        return BackendMode.realDeviceUsb;
    }
  }

  static const String realDeviceUsbBaseUrl = 'http://127.0.0.1:5102/api';
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5102/api';

  static String get backendBaseUrl {
    if (Env.backendBaseUrlOverride.trim().isNotEmpty) {
      return Env.backendBaseUrlOverride;
    }

    switch (activeMode) {
      case BackendMode.realDeviceUsb:
        return realDeviceUsbBaseUrl;
      case BackendMode.androidEmulator:
        return androidEmulatorBaseUrl;
      case BackendMode.realDeviceLan:
        return Env.realDeviceLanBaseUrl;
    }
  }
}
