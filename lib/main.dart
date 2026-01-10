import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/core/theme/app_theme.dart';
import 'package:sakinah_flow/features/splash/splash_screen.dart';
import 'package:sakinah_flow/features/notifications/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database for notifications
  tz.initializeTimeZones();

  // Initialize notification service
  await NotificationService().initialize();

  // Add error handling for uncaught errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🚨 Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(
    const ProviderScope(
      child: SakinahFlowApp(),
    ),
  );
}

class SakinahFlowApp extends StatelessWidget {
  const SakinahFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sakinah Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        // Islamic green theme
        scaffoldBackgroundColor: const Color(0xFF0F3D30),
      ),
      home: const SplashScreen(),
    );
  }
}
