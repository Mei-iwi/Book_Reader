import 'package:book_reader/core/constants/api_constants.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/models/user_model.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

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
}
