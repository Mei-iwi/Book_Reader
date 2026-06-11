import 'package:book_reader/core/constants/api_constants.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/models/admin_user_model.dart';
import 'package:book_reader/data/models/user_model.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  void setToken(String? token) {
    _apiClient.setToken(token);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _apiClient.post(
      ApiConstants.backendBaseUrl,
      ApiConstants.authLogin,
      body: {'email': email, 'password': password},
    );
    final user = UserModel.fromJson(data as Map<String, dynamic>);
    _apiClient.setToken(user.token);
    return user;
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final data = await _apiClient.post(
      ApiConstants.backendBaseUrl,
      ApiConstants.authRegister,
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    final user = UserModel.fromJson(data as Map<String, dynamic>);
    _apiClient.setToken(user.token);
    return user;
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? avatarUrl,
    String? password,
    String? confirmPassword,
  }) async {
    final body = {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'password': password,
      'confirmPassword': confirmPassword,
    };

    dynamic data;
    try {
      data = await _apiClient.put(
        ApiConstants.backendBaseUrl,
        ApiConstants.authMe,
        body: body,
      );
    } catch (e) {
      if (!e.toString().contains('405')) rethrow;
      data = await _apiClient.post(
        ApiConstants.backendBaseUrl,
        ApiConstants.authMe,
        body: body,
      );
    }
    final user = UserModel.fromJson(data as Map<String, dynamic>);
    _apiClient.setToken(user.token);
    return user;
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _apiClient.post(
      ApiConstants.backendBaseUrl,
      ApiConstants.authRequestPasswordReset,
      body: {'email': email},
    );
  }

  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    await _apiClient.post(
      ApiConstants.backendBaseUrl,
      ApiConstants.authVerifyPasswordResetCode,
      body: {'email': email, 'code': code},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    await _apiClient.post(
      ApiConstants.backendBaseUrl,
      ApiConstants.authResetPassword,
      body: {
        'email': email,
        'code': code,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<List<AdminUserModel>> getAdminUsers() async {
    final data = await _apiClient.get(
      ApiConstants.backendBaseUrl,
      ApiConstants.authAdminUsers,
    );
    final list = data is List ? data : <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(AdminUserModel.fromJson)
        .toList();
  }

  Future<AdminUserModel> createAdminUser({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required bool isActive,
    String? phoneNumber,
  }) async {
    final data = await _apiClient.post(
      ApiConstants.backendBaseUrl,
      ApiConstants.authAdminUsers,
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'phoneNumber': phoneNumber,
        'role': role,
        'isActive': isActive,
      },
    );
    return AdminUserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AdminUserModel> updateAdminUser({
    required int userId,
    required String fullName,
    required String email,
    required String role,
    required bool isActive,
    String? phoneNumber,
    String? avatarUrl,
    String? password,
    String? confirmPassword,
  }) async {
    final data = await _apiClient.put(
      ApiConstants.backendBaseUrl,
      '${ApiConstants.authAdminUsers}/$userId',
      body: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
        'isActive': isActive,
      },
    );
    return AdminUserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteAdminUser(int userId) async {
    await _apiClient.delete(
      ApiConstants.backendBaseUrl,
      '${ApiConstants.authAdminUsers}/$userId',
    );
  }
}
