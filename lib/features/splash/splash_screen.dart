import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/features/auth/services/auth_gate.dart';
import 'package:sakinah_flow/features/notifications/services/notification_service.dart';
import 'package:sakinah_flow/l10n/generated/app_localizations.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ref.watch(themeColorsProvider);
    final l = AppLocalizations.of(context);

    useEffect(() {
      // Short, single-shot splash — long enough to let the fade-in finish,
      // then we hand off to AuthGate. The notification permission dialog
      // is moved off the splash path (AuthGate / first-launch UX should
      // request it at the right moment, not while you're still looking at
      // a logo).
      Future.delayed(const Duration(milliseconds: 1500), () async {
        if (!context.mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
        // Fire notification permission request in the background — it'll
        // surface a native dialog over whatever screen comes next without
        // delaying the launch.
        unawaited(_requestNotificationPermissionInBackground());
      });
      return null;
    }, const []);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon: fade in once and HOLD. The earlier code used
              // controller.repeat() which made the logo flicker on/off
              // forever.
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.mosque,
                  size: 60,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 40),

              Text(
                l.appName,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms),

              const SizedBox(height: 12),

              Text(
                l.splashTagline,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 1,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms),

              const SizedBox(height: 60),

              // Spinner: fade in once, the spinning itself comes from
              // CircularProgressIndicator's own animation.
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestNotificationPermissionInBackground() async {
    try {
      final hasPermission = await NotificationService().hasPermission();
      if (!hasPermission) {
        await NotificationService().requestPermission();
      }
    } catch (_) {
      // Best-effort — never block startup on this.
    }
  }
}

