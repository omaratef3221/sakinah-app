import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/features/auth/data/auth_repository.dart';
import 'package:sakinah_flow/features/auth/presentation/screens/login_screen.dart';
import 'package:sakinah_flow/features/auth/providers/auth_provider.dart';
import 'package:sakinah_flow/features/sync/services/sync_service.dart';
import 'package:sakinah_flow/l10n/generated/app_localizations.dart';

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
    final l = AppLocalizations.of(context);
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
              Expanded(
                child: Text(
                  l.accountCardSaveTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.accountCardSaveBody,
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
              child: Text(l.accountCardSignInCta),
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
    final l = AppLocalizations.of(context);
    final confirmed = await _confirmDialog(
      title: l.accountConfirmSignOutTitle,
      body: l.accountConfirmSignOutBody,
      confirmLabel: l.accountSignOut,
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
      if (mounted) _showError(AppLocalizations.of(context).authErrSignOutFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAccount() async {
    final l = AppLocalizations.of(context);
    final confirmed = await _confirmDialog(
      title: l.accountConfirmDeleteTitle,
      body: l.accountConfirmDeleteBody,
      confirmLabel: l.accountDeleteConfirmButton,
      destructive: true,
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      // 1. Wipe Firestore data first while we still have auth. We use
      //    the static helper rather than the SyncController's instance
      //    method so it works even when sync hasn't started (e.g. user
      //    signed in offline, then asked to delete their account).
      final uid = ref.read(authRepositoryProvider).currentUser?.uid;
      if (uid != null) {
        try {
          await SyncService.deleteAllRemoteDataFor(uid: uid);
        } catch (_) {
          // Best-effort — proceed to auth deletion even if remote wipe
          // fails (offline). Apple's guideline is satisfied by the auth
          // deletion; orphan data will be cleaned up by Firestore TTL or
          // a manual sweep.
        }
      }

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
        SnackBar(
          content: Text(AppLocalizations.of(context).accountDeleted),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } on AuthFailure catch (e) {
      _showError(e.message);
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context).accountDeleteFailed);
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
      if (mounted) _showError(AppLocalizations.of(context).accountReauthFailed);
      return false;
    }
  }

  Future<String?> _promptForPassword() async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    bool obscure = true;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l.accountPasswordPromptTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.accountPasswordPromptBody,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l.loginPasswordLabel,
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
              child: Text(l.commonCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(l.commonConfirm),
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
    final l = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
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
    final l = AppLocalizations.of(context);
    final email = user.email ?? '—';
    final name = user.displayName;
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'password';
    final providerLabel = switch (providerId) {
      'google.com' => l.accountProviderGoogle,
      'apple.com' => l.accountProviderApple,
      'password' => l.accountProviderEmail,
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
                      name?.isNotEmpty == true ? name! : l.accountSignedInLabel,
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
                      user.emailVerified
                          ? l.accountSignedInVerified(providerLabel)
                          : l.accountSignedInWith(providerLabel),
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
                  child: Text(l.accountSignOut),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: _busy ? null : _deleteAccount,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                  ),
                  child: Text(l.accountDeleteAccount),
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
        SnackBar(
          content: Text(AppLocalizations.of(context).accountVerifySent),
          backgroundColor: const Color(0xFF10B981),
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
      final l = AppLocalizations.of(context);
      final verified =
          ref.read(authRepositoryProvider).currentUser?.emailVerified ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(verified
              ? l.accountVerifySuccess
              : l.accountVerifyStillNot),
          backgroundColor:
              verified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).accountVerifyRefreshFailed)),
      );
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _sending || _refreshing;
    final l = AppLocalizations.of(context);
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
          Expanded(
            child: Text(
              l.accountVerifyEmail,
              style: const TextStyle(color: Colors.white, fontSize: 13),
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
                : Text(l.accountVerifyRefresh),
          ),
          TextButton(
            onPressed: busy ? null : _resend,
            child: Text(_sending ? '...' : l.accountVerifyResend),
          ),
        ],
      ),
    );
  }
}
