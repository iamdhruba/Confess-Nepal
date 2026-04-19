import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../../../core/utils/night_mode.dart';

class NightModeBanner extends StatelessWidget {
  const NightModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!NightMode.isNightTime) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A2E), Color(0xFF0D0D2A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.moodDark.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 20))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.15, 1.15),
                duration: 2000.ms,
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              NightMode.nightMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.moodDark.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0);
  }
}
