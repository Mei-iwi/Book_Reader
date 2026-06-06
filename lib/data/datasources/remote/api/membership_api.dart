import 'package:book_reader/core/constants/api_constants.dart';
import 'package:book_reader/core/services/http/api_client.dart';

class MembershipPackageModel {
  final int id;
  final String name;
  final double price;
  final int durationDays;
  final String description;

  const MembershipPackageModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.description,
  });

  factory MembershipPackageModel.fromJson(Map<String, dynamic> json) {
    return MembershipPackageModel(
      id: json['id'] is int ? json['id'] as int : 0,
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      durationDays: json['durationDays'] is int
          ? json['durationDays'] as int
          : 0,
      description: json['description']?.toString() ?? '',
    );
  }
}

class UserMembershipModel {
  final int id;
  final int userId;
  final int membershipPackageId;
  final String packageName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  const UserMembershipModel({
    required this.id,
    required this.userId,
    required this.membershipPackageId,
    required this.packageName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory UserMembershipModel.fromJson(Map<String, dynamic> json) {
    return UserMembershipModel(
      id: json['id'] is int ? json['id'] as int : 0,
      userId: json['userId'] is int ? json['userId'] as int : 0,
      membershipPackageId: json['membershipPackageId'] is int
          ? json['membershipPackageId'] as int
          : 0,
      packageName: json['packageName']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'membershipPackageId': membershipPackageId,
      'packageName': packageName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
    };
  }
}

class MembershipApi {
  final ApiClient _apiClient;

  MembershipApi(this._apiClient);

  Future<List<MembershipPackageModel>> getPackages() async {
    final data = await _apiClient.get(
      ApiConstants.backendBaseUrl,
      ApiConstants.membershipPackages,
    );
    final items = data as List<dynamic>? ?? [];
    return items
        .map(
          (item) =>
              MembershipPackageModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<UserMembershipModel> subscribe(int packageId, {int? userId}) async {
    final data = await _apiClient.post(
      ApiConstants.backendBaseUrl,
      '/membership/subscribe/$packageId',
      queryParameters: userId == null ? null : {'userId': userId.toString()},
    );
    return UserMembershipModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserMembershipModel?> getMyPlan({int? userId}) async {
    try {
      final data = await _apiClient.get(
        ApiConstants.backendBaseUrl,
        '/membership/my-plan',
        queryParameters: userId == null ? null : {'userId': userId.toString()},
      );
      return UserMembershipModel.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
