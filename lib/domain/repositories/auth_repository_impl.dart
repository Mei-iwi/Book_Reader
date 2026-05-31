import 'package:book_reader/data/datasources/remote/api/auth_api.dart';
import 'package:book_reader/domain/entities/app_user.dart';
import 'package:book_reader/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;

  AuthRepositoryImpl(this._authApi);

  @override
  void setToken(String? token) {
    _authApi.setToken(token);
  }

  @override
  Future<AppUser> login({required String email, required String password}) {
    return _authApi.login(email: email, password: password);
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _authApi.register(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
