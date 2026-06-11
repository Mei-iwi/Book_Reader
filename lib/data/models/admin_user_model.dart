class AdminUserModel {
  final int userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminUserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    this.phoneNumber = '',
    this.avatarUrl = '',
    this.createdAt,
    this.updatedAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      userId: json['userId'] is int ? json['userId'] as int : 0,
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      role: json['role']?.toString() ?? 'User',
      isActive: json['isActive'] == true,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
