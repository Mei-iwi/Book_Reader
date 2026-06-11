import 'package:book_reader/data/datasources/remote/api/auth_api.dart';
import 'package:book_reader/data/datasources/remote/firebase/firebase_google_auth_datasource.dart';
import 'package:book_reader/data/models/admin_user_model.dart';
import 'package:book_reader/domain/entities/app_user.dart';
import 'package:book_reader/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final FirebaseGoogleAuthDataSource _googleAuthDataSource;

  AuthRepositoryImpl(
    this._authApi, {
    FirebaseGoogleAuthDataSource? googleAuthDataSource,
  }) : _googleAuthDataSource =
           googleAuthDataSource ?? FirebaseGoogleAuthDataSource();

  @override
  void setToken(String? token) {
    _authApi.setToken(token);
  }

  @override
  Future<AppUser> login({required String email, required String password}) {
    return _authApi.login(email: email, password: password);
  }

  @override
  Future<AppUser> signInWithGoogle() {
    return _googleAuthDataSource.signInWithGoogle();
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

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? avatarUrl,
    String? password,
    String? confirmPassword,
  }) {
    return _authApi.updateProfile(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Future<void> requestPasswordReset({required String email}) {
    return _authApi.requestPasswordReset(email: email);
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) {
    return _authApi.verifyPasswordResetCode(email: email, code: code);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) {
    return _authApi.resetPassword(
      email: email,
      code: code,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Future<List<AdminUserModel>> getAdminUsers() {
    return _authApi.getAdminUsers();
  }

  @override
  Future<AdminUserModel> createAdminUser({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required bool isActive,
    String? phoneNumber,
  }) {
    return _authApi.createAdminUser(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
      role: role,
      isActive: isActive,
    );
  }

  @override
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
  }) {
    return _authApi.updateAdminUser(
      userId: userId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      password: password,
      confirmPassword: confirmPassword,
      role: role,
      isActive: isActive,
    );
  }

  @override
  Future<void> deleteAdminUser(int userId) {
    return _authApi.deleteAdminUser(userId);
  }

  @override
  Future<void> signOut() {
    return _googleAuthDataSource.signOut();
  }
}
