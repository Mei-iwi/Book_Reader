import 'dart:convert';
import 'dart:io';

import 'package:book_reader/data/datasources/remote/api/membership_api.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class MembershipProvider extends ChangeNotifier {
  final MembershipApi _membershipApi;

  MembershipProvider(this._membershipApi);

  bool isLoading = false;
  String? errorMessage;
  List<MembershipPackageModel> packages = [];
  UserMembershipModel? currentPlan;

  static const int freeOfflineBookLimit = 3;

  bool get hasActivePlan {
    final plan = currentPlan;
    final endDate = plan?.endDate;
    return plan != null &&
        plan.status.toLowerCase() == 'active' &&
        endDate != null &&
        endDate.isAfter(DateTime.now());
  }

  int get remainingDays {
    final endDate = currentPlan?.endDate;
    if (!hasActivePlan || endDate == null) return 0;
    return endDate.difference(DateTime.now()).inDays + 1;
  }

  int get totalPlanDays {
    final startDate = currentPlan?.startDate;
    final endDate = currentPlan?.endDate;
    if (startDate == null || endDate == null) return 0;
    return endDate.difference(startDate).inDays.clamp(0, 9999).toInt();
  }

  double get planProgress {
    final startDate = currentPlan?.startDate;
    final endDate = currentPlan?.endDate;
    if (!hasActivePlan || startDate == null || endDate == null) return 0;
    final total = endDate.difference(startDate).inSeconds;
    if (total <= 0) return 0;
    final used = DateTime.now().difference(startDate).inSeconds;
    return (used / total).clamp(0, 1).toDouble();
  }

  int? get offlineBookLimit => hasActivePlan ? null : freeOfflineBookLimit;

  bool canSaveOffline(int currentOfflineCount) {
    final limit = offlineBookLimit;
    return limit == null || currentOfflineCount < limit;
  }

  Future<void> loadPackages({int? userId}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      packages = await _membershipApi.getPackages();
      if (userId != null) {
        currentPlan =
            await _membershipApi.getMyPlan(userId: userId) ??
            await _loadCachedPlan(userId);
      }
    } catch (e) {
      if (userId != null) {
        currentPlan ??= await _loadCachedPlan(userId);
      }
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> subscribe(int packageId, {required int userId}) async {
    try {
      currentPlan = await _membershipApi.subscribe(packageId, userId: userId);
      await _cachePlan(userId, currentPlan!);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<File> _cacheFile(int userId) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/membership_$userId.json');
  }

  Future<void> _cachePlan(int userId, UserMembershipModel plan) async {
    final file = await _cacheFile(userId);
    await file.writeAsString(jsonEncode(plan.toJson()));
  }

  Future<UserMembershipModel?> _loadCachedPlan(int userId) async {
    try {
      final file = await _cacheFile(userId);
      if (!await file.exists()) return null;

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;

      final plan = UserMembershipModel.fromJson(decoded);
      final endDate = plan.endDate;
      if (endDate != null && endDate.isBefore(DateTime.now())) return null;
      return plan;
    } catch (_) {
      return null;
    }
  }
}
