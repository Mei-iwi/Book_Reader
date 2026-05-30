import 'package:book_reader/data/datasources/remote/api/membership_api.dart';
import 'package:flutter/foundation.dart';

class MembershipProvider extends ChangeNotifier {
  final MembershipApi _membershipApi;

  MembershipProvider(this._membershipApi);

  bool isLoading = false;
  String? errorMessage;
  List<MembershipPackageModel> packages = [];

  Future<void> loadPackages() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      packages = await _membershipApi.getPackages();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> subscribe(int packageId) async {
    try {
      await _membershipApi.subscribe(packageId, userId: 1);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
