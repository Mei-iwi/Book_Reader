import 'package:book_reader/domain/entities/app_user.dart';
import 'package:book_reader/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  bool isLoading = false;
  String? errorMessage;
  AppUser? currentUser;

  Future<bool> login({required String email, required String password}) async {
    return _runAuth(
      () => _authRepository.login(email: email, password: password),
    );
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return _runAuth(
      () => _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );
  }

  Future<bool> _runAuth(Future<AppUser> Function() action) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      currentUser = await action();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
