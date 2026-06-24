// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/utils/offline_manager.dart';
import 'core/network/dio_client.dart';
import 'core/constants/api_constants.dart';
import 'core/constants/app_strings.dart';
import 'core/utils/network_monitor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Start lightweight network monitoring before app runs
  try {
    NetworkMonitor.instance.start();
  } catch (_) {}

  runApp(const ProviderScope(child: AppRoot()));
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AppRoot extends StatelessWidget {
  const AppRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          MaterialApp.router(
            scaffoldMessengerKey: scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            title: 'Task Manager App',
            routerConfig: router,
            theme: ThemeData(
              primaryColor: const Color(0xFF1A237E),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1A237E),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: OfflineManager.instance.isOffline,
              builder: (context, offline, child) {
                if (!offline) return const SizedBox.shrink();
                return SafeArea(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 12.0,
                    ),
                    color: Colors.orangeAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            AppStrings.offlineMode,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final messenger = scaffoldMessengerKey.currentState;
                            try {
                              messenger?.showSnackBar(
                                const SnackBar(
                                  content: Text('Checking network...'),
                                ),
                              );
                              final resp = await DioClient().dio.get(
                                ApiConstants.users,
                              );
                              if (resp.statusCode == 200) {
                                OfflineManager.instance.setOffline(false);
                                messenger?.showSnackBar(
                                  const SnackBar(
                                    content: Text('Back online'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                messenger?.showSnackBar(
                                  const SnackBar(
                                    content: Text('Still offline'),
                                  ),
                                );
                              }
                            } catch (e) {
                              messenger?.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Still offline: ${e.toString()}',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
