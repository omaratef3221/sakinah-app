import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/features/auth/data/auth_repository.dart';
import 'package:sakinah_flow/features/auth/presentation/screens/login_screen.dart';
import 'package:sakinah_flow/features/auth/providers/auth_provider.dart';
import 'package:sakinah_flow/features/sync/providers/sync_provider.dart';

/// Account / sign-in card shown at the top of Settings.
///
/// - Guest user: prompts sign-in
/// - Signed-in user: shows email + sign-out + delete-account
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch both: authStateChanges fires on sign-in/out, refreshTick fires
    // when we reload the user to pick up emailVerified after verification.
    final streamUser = ref.watch(authStateChangesProvider).valueOrNull;
    ref.watch(authRefreshTickProvider);
    // Read the live FirebaseAuth.currentUser so we always show the freshest
    // emailVerified flag (the stream caches the User object).
    final liveUser = ref.read(authRepositoryProvider).currentUser;
    final user = liveUser ?? streamUser;

    if (user == null) {
      return const _GuestCard();
    }
    return _SignedInCard(user: user);
  }
}

class _GuestCard extends ConsumerWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cloud_upload_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save your progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'احفظ تقدّمك',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to back up your habits and streaks across devices.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Drop guest mode and route through AuthGate by pushing the
                // login screen.
                await ref.read(guestModeProvider.notifier).set(false);
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Sign In or Create Account'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedInCard extends ConsumerStatefulWidget {
  final User user;
  const _SignedInCard({required this.user});

  @override
  ConsumerState<_SignedInCard> createState() => _SignedInCardState();
}

class _SignedInCardState extends ConsumerState<_SignedInCard> {
  bool _busy = false;

  Future<void> _signOut() async {
    final confirmed = await _confirmDialog(
      title: 'Sign out?',
      body:
          'Your local data stays on this device. Sign back in any time to resume cloud backup.',
      confirmLabel: 'Sign out',
      destructive: false,
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      // Returning to guest mode = false so AuthGate shows the login screen
      // again (rather than silently treating them as guest).
      await ref.read(guestModeProvider.notifier).set(false);
    } catch (e) {
      _showError('Sign out failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _confirmDialog(
      title: 'Delete account?',
      body:
          'This permanently deletes your account and all cloud data. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      // 1. Wipe Firestore data first while we still have auth.
      await ref.read(syncControllerProvider.notifier).deleteAllRemoteData();

      // 2. Try to delete the auth account. May require recent login.
      try {
        await ref.read(authRepositoryProvider).deleteAccount();
      } on AuthFailure catch (e) {
        if (e.code == 'requires-recent-login') {
          final reauthed = await _reauthCurrentUser();
          if (!reauthed) return; // user cancelled or failed
          await ref.read(authRepositoryProvider).deleteAccount();
        } else {
          rethrow;
        }
      }

      // 3. Reset local guest flag.
      await ref.read(guestModeProvider.notifier).set(false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } on AuthFailure catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Could not delete account: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Re-authenticates the current user via the appropriate flow for their
  /// sign-in provider. For password users this prompts for the password
  /// inline. Returns true on success, false if the user cancelled or
  /// re-auth failed (the failure has already been shown via snackbar).
  Future<bool> _reauthCurrentUser() async {
    final providerId = widget.user.providerData.isNotEmpty
        ? widget.user.providerData.first.providerId
        : 'password';
    try {
      if (providerId == 'password') {
        final password = await _promptForPassword();
        if (password == null || password.isEmpty) return false;
        await ref
            .read(authRepositoryProvider)
            .reauthenticateWithPassword(password);
      } else {
        // Apple / Google: re-running the sign-in flow performs reauth.
        await ref.read(authRepositoryProvider).reauthenticate();
      }
      return true;
    } on AuthFailure catch (e) {
      if (e.code == 'cancelled') return false;
      _showError(e.message);
      return false;
    } catch (e) {
      _showError('Could not re-authenticate: $e');
      return false;
    }
  }

  Future<String?> _promptForPassword() async {
    final controller = TextEditingController();
    bool obscure = true;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Confirm your password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'For security, please enter your password to confirm account deletion.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded),
                    onPressed: () =>
                        setDialogState(() => obscure = !obscure),
                  ),
                ),
                onSubmitted: (v) => Navigator.of(context).pop(v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<bool> _confirmDialog({
    required String title,
    required String body,
    required String confirmLabel,
    required bool destructive,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: destructive
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFD4AF37),
              foregroundColor:
                  destructive ? Colors.white : const Color(0xFF0A1F1A),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
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
    final user = widget.user;
    final email = user.email ?? '—';
    final name = user.displayName;
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'password';
    final providerLabel = switch (providerId) {
      'google.com' => 'Google',
      'apple.com' => 'Apple',
      'password' => 'Email',
      _ => providerId,
    };

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFD4AF37),
                child: Text(
                  (name?.isNotEmpty == true
                          ? name![0]
                          : email.isNotEmpty
                              ? email[0]
                              : '?')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF0A1F1A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name?.isNotEmpty == true ? name! : 'Signed in',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Signed in with $providerLabel${user.emailVerified ? ' • verified' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (user.email != null && !user.emailVerified) ...[
            const SizedBox(height: 12),
            _VerifyEmailRow(),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _signOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  child: const Text('Sign out'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: _busy ? null : _deleteAccount,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                  ),
                  child: const Text('Delete account'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifyEmailRow extends ConsumerStatefulWidget {
  @override
  ConsumerState<_VerifyEmailRow> createState() => _VerifyEmailRowState();
}

class _VerifyEmailRowState extends ConsumerState<_VerifyEmailRow> {
  bool _sending = false;
  bool _refreshing = false;

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      // Firebase caches the verified flag locally; reload pulls fresh state.
      await ref.read(authRepositoryProvider).reloadCurrentUser();
      // authStateChanges() does NOT fire on reload(). Bump our tick to
      // force AccountSection to rebuild with the now-updated currentUser.
      // (Don't invalidate authStateChangesProvider — that would tear down
      // every Firestore listener wired to it via SyncController.)
      ref.read(authRefreshTickProvider.notifier).bump();

      if (!mounted) return;
      final verified =
          ref.read(authRepositoryProvider).currentUser?.emailVerified ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(verified
              ? 'Email verified — thanks!'
              : 'Not verified yet. Click the link in the email, then tap Refresh again.'),
          backgroundColor:
              verified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not refresh: $e')),
      );
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _sending || _refreshing;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.mark_email_unread_rounded,
              color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Verify your email',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: busy ? null : _refresh,
            child: _refreshing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Refresh'),
          ),
          TextButton(
            onPressed: busy ? null : _resend,
            child: Text(_sending ? '...' : 'Resend'),
          ),
        ],
      ),
    );
  }
}
