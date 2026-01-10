import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/features/home/presentation/main_navigation.dart';
import 'package:sakinah_flow/features/notifications/services/notification_service.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ref.watch(themeColorsProvider);

    useEffect(() {
      // Navigate to dashboard after 3 seconds and request notification permission
      Future.delayed(const Duration(seconds: 3), () async {
        if (context.mounted) {
          // Request notification permission directly from the system
          final hasPermission = await NotificationService().hasPermission();
          if (!hasPermission) {
            // This will trigger the native iOS/Android permission dialog
            await NotificationService().requestPermission();
          }

          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigation()),
            );
          }
        }
      });
      return null;
    }, []);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.mosque,
                  size: 60,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 1000.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 1000.ms,
                  ),

              const SizedBox(height: 40),

              // App Name
              const Text(
                'Sakinah',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, duration: 800.ms),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Find Peace in Every Moment',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1,
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, duration: 800.ms),

              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(delay: 1000.ms, duration: 500.ms),

              const SizedBox(height: 20),

              // Loading text
              Text(
                'Loading your spiritual journey...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .fadeIn(delay: 1200.ms, duration: 1500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
