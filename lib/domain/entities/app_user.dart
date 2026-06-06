class AppUser {
  final int userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final String role;
  final String token;

  const AppUser({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber = '',
    this.avatarUrl = '',
    required this.role,
    required this.token,
  });
}
