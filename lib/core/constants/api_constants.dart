import 'package:book_reader/config/backend_environment.dart';

class ApiConstants {
  static const String googleBooksBaseUrl = 'https://www.googleapis.com';
  static const String volumesEndpoint = '/books/v1/volumes';

  static String get backendBaseUrl => BackendEnvironment.backendBaseUrl;

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authRequestPasswordReset =
      '/auth/request-password-reset';
  static const String authVerifyPasswordResetCode =
      '/auth/verify-password-reset-code';
  static const String authResetPassword = '/auth/reset-password';
  static const String authAdminUsers = '/auth/admin/users';
  static const String books = '/books';
  static const String googleBooksSearch = '/books/google/search';
  static const String library = '/library';
  static const String readingProgress = '/reading-progress';
  static const String bookmarks = '/bookmarks';
  static const String notes = '/notes';
  static const String membershipPackages = '/membership/packages';
}
