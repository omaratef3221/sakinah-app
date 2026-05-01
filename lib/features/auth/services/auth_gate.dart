import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/features/auth/presentation/screens/login_screen.dart';
import 'package:sakinah_flow/features/auth/providers/auth_provider.dart';
import 'package:sakinah_flow/features/home/presentation/main_navigation.dart';
import 'package:sakinah_flow/features/sync/providers/sync_provider.dart';

/// Routes the user to either [LoginScreen] or [MainNavigation] based on
/// their auth + guest-mode state. Also kicks off cloud sync once the user
/// is signed in.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final guestState = ref.watch(guestModeProvider);

    // Trigger sync as a side effect when the user is signed in.
    // The sync provider itself watches auth state and idempotently starts
    // / stops on changes — calling .read here just ensures it's instantiated.
    ref.listen<AsyncValue<dynamic>>(authStateChangesProvider, (_, __) {
      ref.read(syncControllerProvider);
    });

    return authState.when(
      loading: () => const _LoadingScaffold(),
      error: (e, _) => _ErrorScaffold(error: e.toString()),
      data: (user) {
        if (user != null) {
          // Make sure sync controller is initialized.
          ref.read(syncControllerProvider);
          return const MainNavigation();
        }
        return guestState.when(
          loading: () => const _LoadingScaffold(),
          error: (e, _) => _ErrorScaffold(error: e.toString()),
          data: (isGuest) =>
              isGuest ? const MainNavigation() : const LoginScreen(),
        );
      },
    );
  }
}

class _LoadingScaffold extends ConsumerWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ref.watch(themeColorsProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.backgroundGradient),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}

class _ErrorScaffold extends ConsumerWidget {
  final String error;
  const _ErrorScaffold({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ref.watch(themeColorsProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.backgroundGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Something went wrong: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
