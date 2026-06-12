import 'package:flutter/foundation.dart';

class ProfileRefreshProvider extends ChangeNotifier {
  int _revision = 0;

  int get revision => _revision;

  void requestRefresh() {
    _revision++;
    notifyListeners();
  }
}
