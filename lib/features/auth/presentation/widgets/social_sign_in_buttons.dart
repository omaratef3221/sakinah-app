import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/features/auth/data/auth_repository.dart';
import 'package:sakinah_flow/features/auth/providers/auth_provider.dart';

/// Apple + Google sign-in buttons. Apple is hidden on platforms where
/// Sign in with Apple isn't available (per Apple's guideline 4.8).
class SocialSignInButtons extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  const SocialSignInButtons({super.key, this.onSuccess});

  @override
  ConsumerState<SocialSignInButtons> createState() =>
      _SocialSignInButtonsState();
}

class _SocialSignInButtonsState extends ConsumerState<SocialSignInButtons> {
  bool _appleLoading = false;
  bool _googleLoading = false;

  Future<void> _signInWithApple() async {
    setState(() => _appleLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithApple();
      widget.onSuccess?.call();
    } on AuthFailure catch (e) {
      if (e.code == 'cancelled') return;
      _showError(e.message);
    } catch (e) {
      _showError('Apple sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _appleLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      widget.onSuccess?.call();
    } on AuthFailure catch (e) {
      if (e.code == 'cancelled') return;
      _showError(e.message);
    } catch (e) {
      _showError('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showApple = ref.read(authRepositoryProvider).isAppleSignInAvailable;

    return Column(
      children: [
        if (showApple) ...[
          _SocialButton(
            label: 'Continue with Apple',
            icon: Icons.apple,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            isLoading: _appleLoading,
            onPressed: (_appleLoading || _googleLoading) ? null : _signInWithApple,
          ),
          const SizedBox(height: 12),
        ],
        _SocialButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata_rounded,
          iconSize: 32,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF202124),
          isLoading: _googleLoading,
          onPressed: (_appleLoading || _googleLoading) ? null : _signInWithGoogle,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final double iconSize;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    this.iconSize = 22,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(foregroundColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: iconSize),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
