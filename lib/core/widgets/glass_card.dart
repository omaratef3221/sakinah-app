import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism card widget with blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double blur;
  final Gradient? gradient;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.color,
    this.blur = 10,
    this.gradient,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.1),
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Frosted glass effect for backgrounds
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
