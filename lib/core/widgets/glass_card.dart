import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism card.
///
/// `BackdropFilter` is expensive on mobile, especially when many cards are
/// stacked on the same screen. The visual context here is a solid gradient
/// background, so a real blur adds little — we fake the frosted look with a
/// translucent fill + soft border. Pass `useBlur: true` for the real effect
/// when there's actual content behind (e.g. an image).
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double blur;
  final Gradient? gradient;
  final Border? border;
  final bool useBlur;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.color,
    this.blur = 10,
    this.gradient,
    this.border,
    this.useBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Colors.white.withValues(alpha: 0.08)) : null,
        gradient: gradient,
        borderRadius: radius,
        border: border ??
            Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (!useBlur) {
      return ClipRRect(borderRadius: radius, child: container);
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: container,
      ),
    );
  }
}

/// Frosted glass effect for backgrounds. Kept for compatibility; prefer
/// avoiding when not strictly needed.
class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;

  const FrostedGlass({
    super.key,
    required this.child,
    this.blur = 10,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          color: color ?? Colors.white.withValues(alpha: 0.1),
          child: child,
        ),
      ),
    );
  }
}
