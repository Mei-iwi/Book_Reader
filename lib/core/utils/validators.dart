class AppValidators {
  AppValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(r'^[0-9]{9,11}$');

  static String? requiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredText(value, 'email');
    if (requiredError != null) return requiredError;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? emailOrPhone(String? value) {
    final requiredError = requiredText(value, 'email hoac so dien thoai');
    if (requiredError != null) return requiredError;

    final text = value!.trim();
    if (_emailRegex.hasMatch(text) || _phoneRegex.hasMatch(text)) {
      return null;
    }
    return 'Hay nhap email hoac so dien thoai hop le';
  }

  static String? password(String? value, {int minLength = 6}) {
    final requiredError = requiredText(value, 'mat khau');
    if (requiredError != null) return requiredError;
    if (value!.length < minLength) {
      return 'Mật khẩu phải có ít nhất $minLength ký tự';
    }
    return null;
  }

  static String? confirmPassword(String? value, String passwordValue) {
    final requiredError = requiredText(value, 'mat khau xac nhan');
    if (requiredError != null) return requiredError;
    if (value != passwordValue) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  static String? maxLength(String? value, int max, String fieldName) {
    if (value != null && value.trim().length > max) {
      return '$fieldName không được quá $max ký tự';
    }
    return null;
  }

  static String? optionalPhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!_phoneRegex.hasMatch(text)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }
}
