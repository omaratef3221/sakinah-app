import 'package:flutter/material.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                  ),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: const Color(0xFF0A1F1A),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      actionText!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A1F1A),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
