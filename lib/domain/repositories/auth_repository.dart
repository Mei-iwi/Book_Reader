import 'package:book_reader/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  });
}
