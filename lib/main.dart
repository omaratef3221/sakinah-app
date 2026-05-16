import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/core/providers/locale_provider.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/core/theme/app_theme.dart';
import 'package:sakinah_flow/features/splash/splash_screen.dart';
import 'package:sakinah_flow/features/notifications/services/notification_service.dart';
import 'package:sakinah_flow/firebase_options.dart';
import 'package:sakinah_flow/l10n/generated/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    final locale = ref.watch(localeProvider);
    final isArabic = locale?.languageCode == 'ar';
    return MaterialApp(
      title: 'Sakinah Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(themeColors, isArabic: isArabic),
      // Localization. `localeResolutionCallback` falls back to English when
      // the device language isn't one we ship — instead of Flutter's
      // default of "first supported locale" which can surprise people.
      locale: locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supported) {
        if (locale != null) return locale; // user explicitly chose
        for (final s in supported) {
          if (deviceLocale?.languageCode == s.languageCode) return s;
        }
        return const Locale('en');
      },
      home: const SplashScreen(),
    );
  }
}
