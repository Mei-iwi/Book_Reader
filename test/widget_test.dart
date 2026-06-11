import 'package:book_reader/core/services/local_storage/session_storage.dart';
import 'package:book_reader/data/models/admin_user_model.dart';
import 'package:book_reader/domain/entities/app_user.dart';
import 'package:book_reader/domain/repositories/auth_repository.dart';
import 'package:book_reader/presentation/pages/auth/login.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Login landing screen shows auth actions', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(_FakeAuthRepository(), SessionStorage()),
        child: const MaterialApp(home: Login()),
      ),
    );

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  void setToken(String? token) {}

  @override
  Future<AppUser> login({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

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
    // TODO: implement createAdminUser
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAdminUser(int userId) {
    // TODO: implement deleteAdminUser
    throw UnimplementedError();
  }

  @override
  Future<List<AdminUserModel>> getAdminUsers() {
    // TODO: implement getAdminUsers
    throw UnimplementedError();
  }

  @override
  Future<void> requestPasswordReset({required String email}) {
    // TODO: implement requestPasswordReset
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) {
    // TODO: implement resetPassword
    throw UnimplementedError();
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
    // TODO: implement updateAdminUser
    throw UnimplementedError();
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) {
    // TODO: implement verifyPasswordResetCode
    throw UnimplementedError();
  }
}
