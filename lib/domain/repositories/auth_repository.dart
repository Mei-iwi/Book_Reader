import 'package:book_reader/domain/entities/app_user.dart';

abstract class AuthRepository {
  void setToken(String? token);

  Future<AppUser> login({required String email, required String password});

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  });
}
