import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/home/presentation/main_navigation.dart';

class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(initializeDatabaseProvider);

    return initAsync.when(
      data: (_) => const MainNavigation(),
      loading: () => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A5F4E),
              Color(0xFF0F3D30),
              Color(0xFF0A1F1A),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mosque_rounded,
                size: 80,
                color: Color(0xFFD4AF37),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              ),
              SizedBox(height: 16),
              Text(
                'Sakinah Flow',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'سكينة',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A5F4E),
              Color(0xFF0F3D30),
              Color(0xFF0A1F1A),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
