import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 120,
                color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'لوحة المتصدرين',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
