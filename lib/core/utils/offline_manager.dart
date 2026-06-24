import 'package:flutter/foundation.dart';

class OfflineManager {
  OfflineManager._();

  static final OfflineManager instance = OfflineManager._();

  final ValueNotifier<bool> isOffline = ValueNotifier<bool>(false);

  void setOffline(bool value) {
    isOffline.value = value;
  }

  void dispose() {
    isOffline.dispose();
  }
}
