import 'package:book_reader/data/models/admin_user_model.dart';
import 'package:book_reader/domain/entities/app_user.dart';

abstract class AuthRepository {
  void setToken(String? token);

  Future<AppUser> login({required String email, required String password});

  Future<AppUser> signInWithGoogle();

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<AppUser> updateProfile({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? avatarUrl,
    String? password,
    String? confirmPassword,
  });

  Future<void> requestPasswordReset({required String email});

  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  });

  Future<List<AdminUserModel>> getAdminUsers();

  Future<AdminUserModel> createAdminUser({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required bool isActive,
    String? phoneNumber,
  });

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
  });

  Future<void> deleteAdminUser(int userId);

  Future<void> signOut();
}
