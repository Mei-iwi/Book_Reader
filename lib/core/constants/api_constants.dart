class ApiConstants {
  static const String googleBooksBaseUrl = 'https://www.googleapis.com';
  static const String volumesEndpoint = '/books/v1/volumes';

  // Android emulator maps host machine localhost to 10.0.2.2.
  // For a real phone, replace 10.0.2.2 with the LAN IP of the backend machine.
  static const String backendBaseUrl = 'http://10.0.2.2:5102/api';

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String books = '/books';
  static const String googleBooksSearch = '/books/google/search';
  static const String library = '/library';
  static const String readingProgress = '/reading-progress';
  static const String bookmarks = '/bookmarks';
  static const String notes = '/notes';
  static const String membershipPackages = '/membership/packages';
}
