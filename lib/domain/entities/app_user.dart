class AppUser {
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final String token;

  const AppUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.token,
  });
}
