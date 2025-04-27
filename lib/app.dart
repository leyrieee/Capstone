// app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'providers/alerts_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/backend_service.dart';
import 'services/storage_service.dart';
import 'theme.dart';

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({
    required this.notificationService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BackendService>(
          create: (_) => BackendService(),
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        Provider<NotificationService>.value(
          value: notificationService,
        ),
        ChangeNotifierProxyProvider<BackendService, AlertsProvider>(
          create: (context) => AlertsProvider(
            Provider.of<BackendService>(context, listen: false),
          ),
          update: (context, backend, previous) => previous!..update(backend),
        ),
        ChangeNotifierProxyProvider<StorageService, SettingsProvider>(
          create: (context) => SettingsProvider(
            Provider.of<StorageService>(context, listen: false),
          ),
          update: (context, storage, previous) => previous!..update(storage),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp.router(
            title: 'NeuroScope',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settingsProvider.darkModeEnabled
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
