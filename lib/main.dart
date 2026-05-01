import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/core/theme/app_theme.dart';
import 'package:sakinah_flow/features/splash/splash_screen.dart';
import 'package:sakinah_flow/features/notifications/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await NotificationService().initialize();

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

class SakinahFlowApp extends ConsumerWidget {
  const SakinahFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ref.watch(themeColorsProvider);
    return MaterialApp(
      title: 'Sakinah Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(themeColors),
      home: const SplashScreen(),
    );
  }
}
