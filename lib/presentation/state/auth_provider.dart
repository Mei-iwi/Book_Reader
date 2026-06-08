import 'package:book_reader/core/services/local_storage/session_storage.dart';
import 'package:book_reader/data/models/user_model.dart';
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

  Future<bool> loginWithGoogle() async {
    return _runAuth(() => _authRepository.signInWithGoogle());
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
      _authRepository.setToken(currentUser!.token);
      return true;
    } catch (e) {
      debugPrint('Auth API Error: $e');
      currentUser = null;
      _authRepository.setToken(null);
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
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
    await _authRepository.signOut();
    _authRepository.setToken(null);
    currentUser = null;
    _sessionChecked = true;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? avatarUrl,
    String? password,
    String? confirmPassword,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      currentUser = await _authRepository.updateProfile(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        password: password,
        confirmPassword: confirmPassword,
      );
      if (currentUser != null &&
          avatarUrl != null &&
          avatarUrl.trim().isNotEmpty &&
          currentUser!.avatarUrl != avatarUrl) {
        currentUser = UserModel(
          userId: currentUser!.userId,
          fullName: currentUser!.fullName,
          email: currentUser!.email,
          phoneNumber: currentUser!.phoneNumber,
          avatarUrl: avatarUrl,
          role: currentUser!.role,
          token: currentUser!.token,
        );
      }
      await _sessionStorage.saveUser(currentUser!);
      _authRepository.setToken(currentUser!.token);
      return true;
    } catch (e) {
      if (e.toString().contains('405') && currentUser != null) {
        currentUser = UserModel(
          userId: currentUser!.userId,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber ?? currentUser!.phoneNumber,
          avatarUrl: avatarUrl ?? currentUser!.avatarUrl,
          role: currentUser!.role,
          token: currentUser!.token,
        );
        await _sessionStorage.saveUser(currentUser!);
        errorMessage = null;
        return true;
      }
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
