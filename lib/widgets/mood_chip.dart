import 'package:flutter/material.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';

class MoodChip extends StatelessWidget {
  final String mood;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const MoodChip({
    super.key,
    required this.mood,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.moodColor(mood);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class MoodFilterBar extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String?> onMoodSelected;

  const MoodFilterBar({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  static const _moods = [
    {'key': 'sad', 'label': 'Sad'},
    {'key': 'love', 'label': 'Love'},
    {'key': 'funny', 'label': 'Funny'},
    {'key': 'dark', 'label': 'Dark'},
    {'key': 'confused', 'label': 'Confused'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _moods.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () => onMoodSelected(null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: selectedMood == null
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: selectedMood == null
                        ? AppColors.primary.withOpacity(0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'All',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: selectedMood == null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: selectedMood == null
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                ),
              ),
            );
          }

          final mood = _moods[index - 1];
          return MoodChip(
            mood: mood['key']!,
            label: mood['label']!,
            isSelected: selectedMood == mood['key'],
            onTap: () => onMoodSelected(mood['key']),
          );
        },
      ),
    );
  }
}
