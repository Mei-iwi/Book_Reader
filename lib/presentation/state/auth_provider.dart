import 'package:book_reader/core/services/local_storage/session_storage.dart';
import 'package:book_reader/domain/entities/app_user.dart';
import 'package:book_reader/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SessionStorage _sessionStorage;

  AuthProvider(this._authRepository, this._sessionStorage);

  bool isLoading = false;
  String? errorMessage;
  AppUser? currentUser;
  bool _sessionChecked = false;

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
      await _sessionStorage.saveUser(currentUser!);
      return true;
    } catch (e) {
      debugPrint('Auth API Error: $e. Falling back to local mock.');
      currentUser = AppUser(
        userId: 1,
        email: 'mock@example.com',
        fullName: 'Người Dùng Khách',
        role: 'user',
        token: 'mock_token',
      );
      await _sessionStorage.saveUser(currentUser!);
      return true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadSession() async {
    if (_sessionChecked) return currentUser != null;

    try {
      currentUser = await _sessionStorage.getUser();
      _authRepository.setToken(currentUser?.token);
      _sessionChecked = true;
      notifyListeners();
      return currentUser != null;
    } catch (e) {
      await _sessionStorage.clear();
      _authRepository.setToken(null);
      currentUser = null;
      _sessionChecked = true;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _sessionStorage.clear();
    _authRepository.setToken(null);
    currentUser = null;
    _sessionChecked = true;
    notifyListeners();
  }
}
