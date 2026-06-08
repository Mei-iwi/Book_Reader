enum BackendRunTarget { emulator, physicalUsb, physicalLan }

class BackendEnvironment {
  // Doi dong nay khi muon chay nhanh giua may ao va may that.
  static const BackendRunTarget activeTarget = BackendRunTarget.emulator;

  static const String scheme = 'http';
  static const int port = 5102;

  static const String emulatorHost = '10.0.2.2';

  // May that cam USB: chay them `adb reverse tcp:5102 tcp:5102`.
  static const String physicalUsbHost = '127.0.0.1';

  // May that qua Wi-Fi/LAN: doi thanh IP cua may dang chay backend.
  static const String physicalLanHost = '192.168.1.10';

  static String get backendBaseUrl => '$scheme://$host:$port/api';

  static String get host {
    const overrideHost = String.fromEnvironment('BACKEND_HOST');
    if (overrideHost.trim().isNotEmpty) return overrideHost;

    return switch (_targetName) {
      'emulator' => emulatorHost,
      'physicalLan' => physicalLanHost,
      _ => physicalUsbHost,
    };
  }

  static String get _targetName {
    const overrideTarget = String.fromEnvironment('BACKEND_TARGET');
    if (overrideTarget.trim().isNotEmpty) return overrideTarget.trim();

    return switch (activeTarget) {
      BackendRunTarget.emulator => 'emulator',
      BackendRunTarget.physicalUsb => 'physicalUsb',
      BackendRunTarget.physicalLan => 'physicalLan',
    };
  }
}
