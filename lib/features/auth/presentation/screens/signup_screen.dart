import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/features/auth/data/auth_repository.dart';
import 'package:sakinah_flow/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:sakinah_flow/features/auth/presentation/widgets/social_sign_in_buttons.dart';
import 'package:sakinah_flow/features/auth/providers/auth_provider.dart';
import 'package:sakinah_flow/l10n/generated/app_localizations.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          );
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      // Capture the root messenger BEFORE popping — otherwise the snackbar
      // attaches to this screen's messenger and is dismissed instantly.
      final rootMessenger = ScaffoldMessenger.maybeOf(
        Navigator.of(context, rootNavigator: true).context,
      ) ??
          ScaffoldMessenger.of(context);
      Navigator.of(context).popUntil((route) => route.isFirst);
      rootMessenger.showSnackBar(
        SnackBar(
          content: Text(l.signupSuccess),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } on AuthFailure catch (e) {
      _showError(e.message);
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context).signupErrorGeneric);
    } finally {
      if (mounted) setState(() => _loading = false);
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
    final themeColors = ref.watch(themeColorsProvider);
    final l = AppLocalizations.of(context);

    // Pop back to first route when sign-in succeeds (covers Apple/Google
    // social sign-in from this screen too).
    ref.listen(authStateChangesProvider, (prev, next) {
      final user = next.valueOrNull;
      if (user != null && Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    l.signupTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.signupSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AuthTextField(
                    controller: _nameController,
                    label: l.signupNameLabel,
                    hint: l.signupNameHint,
                    icon: Icons.person_rounded,
                    keyboardType: TextInputType.name,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l.signupNameError
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _emailController,
                    label: l.loginEmailLabel,
                    hint: l.loginEmailHint,
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => _validateEmail(v, l),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _passwordController,
                    label: l.loginPasswordLabel,
                    hint: l.signupPasswordHint,
                    icon: Icons.lock_rounded,
                    obscure: _obscurePassword,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    onSuffixTap: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return l.signupPasswordEmptyError;
                      }
                      if (v.length < 6) return l.signupPasswordShortError;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _confirmController,
                    label: l.signupConfirmPasswordLabel,
                    hint: l.signupConfirmPasswordHint,
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _signUp(),
                    suffixIcon: _obscureConfirm
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    onSuffixTap: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return l.signupConfirmEmptyError;
                      }
                      if (v != _passwordController.text) {
                        return l.signupConfirmMismatchError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signUp,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : Text(l.signupButton),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          l.commonOr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SocialSignInButtons(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(String? value, AppLocalizations l) {
  if (value == null || value.trim().isEmpty) return l.loginErrorEnterEmail;
  final email = value.trim();
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!regex.hasMatch(email)) return l.loginErrorInvalidEmail;
  return null;
}
