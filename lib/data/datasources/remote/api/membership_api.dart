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

  Future<void> subscribe(int packageId, {int? userId}) async {
    await _apiClient.post(
      ApiConstants.backendBaseUrl,
      '/membership/subscribe/$packageId',
      queryParameters: userId == null ? null : {'userId': userId.toString()},
    );
  }
}
