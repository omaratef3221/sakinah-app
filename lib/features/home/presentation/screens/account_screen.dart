import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/features/auth/presentation/widgets/account_section.dart';
import 'package:sakinah_flow/features/auth/providers/auth_provider.dart';
import 'package:sakinah_flow/l10n/generated/app_localizations.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final themeColors = ref.watch(themeColorsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _AccountHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const AccountSection(),
                    if (user != null) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(
                          AppLocalizations.of(context).accountDetailsHeader),
                      const SizedBox(height: 12),
                      _AccountDetailsCard(user: user),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            AppLocalizations.of(context).accountScreenTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFD4AF37),
      ),
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  final User user;
  const _AccountDetailsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).toString();
    final formatter = DateFormat.yMMMMd(localeStr).add_jm();
    final created = user.metadata.creationTime;
    final lastSignIn = user.metadata.lastSignInTime;
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'password';
    final providerLabel = switch (providerId) {
      'google.com' => l.accountProviderGoogle,
      'apple.com' => l.accountProviderApple,
      'password' => l.accountProviderEmailLong,
      _ => providerId,
    };

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.email_rounded,
            label: l.accountFieldEmail,
            value: user.email ?? '—',
          ),
          if (user.displayName != null && user.displayName!.isNotEmpty)
            _DetailRow(
              icon: Icons.person_rounded,
              label: l.accountFieldName,
              value: user.displayName!,
            ),
          _DetailRow(
            icon: Icons.verified_user_rounded,
            label: l.accountFieldSignInMethod,
            value: providerLabel,
          ),
          _DetailRow(
            icon: Icons.shield_rounded,
            label: l.accountFieldEmailVerified,
            value: user.emailVerified
                ? l.accountFieldEmailVerifiedYes
                : l.accountFieldEmailVerifiedNo,
            valueColor: user.emailVerified
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
          ),
          if (created != null)
            _DetailRow(
              icon: Icons.calendar_today_rounded,
              label: l.accountFieldJoined,
              value: formatter.format(created),
            ),
          if (lastSignIn != null)
            _DetailRow(
              icon: Icons.schedule_rounded,
              label: l.accountFieldLastSignIn,
              value: formatter.format(lastSignIn),
            ),
          _DetailRow(
            icon: Icons.fingerprint_rounded,
            label: l.accountFieldUserId,
            value: user.uid,
            monospace: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool monospace;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.monospace = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.white,
                fontFamily: monospace ? 'monospace' : null,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
