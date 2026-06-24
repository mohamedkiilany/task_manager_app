import 'dart:async';

import '../network/dio_client.dart';
import '../constants/api_constants.dart';
import 'offline_manager.dart';

class NetworkMonitor {
  NetworkMonitor._();
  static final NetworkMonitor instance = NetworkMonitor._();

  Timer? _timer;

  void start({Duration interval = const Duration(seconds: 8)}) {
    // immediate probe
    _probe().then((ok) => OfflineManager.instance.setOffline(!ok));

    _timer ??= Timer.periodic(interval, (_) async {
      final ok = await _probe();
      OfflineManager.instance.setOffline(!ok);
    });
  }

  Future<bool> _probe() async {
  try {
    final resp = await DioClient().dio.get(ApiConstants.users);
    print('Probe success: ${resp.statusCode}');
    return resp.statusCode == 200;
  } catch (e) {
    print('Probe error: $e');
    return false;
  }
}

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
