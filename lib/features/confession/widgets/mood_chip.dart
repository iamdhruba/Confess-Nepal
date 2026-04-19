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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15) 
              : Theme.of(context).cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected 
                ? color.withOpacity(0.4) 
                : Theme.of(context).dividerColor.withOpacity(0.08),
            width: 1.2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

class MoodFilterBar extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String?> onMoodSelected;
  final List<String> dynamicMoods;

  MoodFilterBar({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
    this.dynamicMoods = const [],
  });

  static const _defaultMoods = [
    {'key': 'sad', 'label': 'Sad'},
    {'key': 'love', 'label': 'Love'},
    {'key': 'funny', 'label': 'Funny'},
    {'key': 'dark', 'label': 'Dark'},
    {'key': 'confused', 'label': 'Confused'},
  ];

  @override
  Widget build(BuildContext context) {
    // Safety check for dynamicMoods nullability (though it has a default)
    final moodsList = dynamicMoods;
    final List<Map<String, String>> allMoods = List.from(_defaultMoods);
    
    for (final mood in moodsList) {
      // ignore: unnecessary_null_comparison
      if (mood != null && mood.isNotEmpty) {
        final lowerMood = mood.toLowerCase();
        if (!allMoods.any((m) => m['key']?.toLowerCase() == lowerMood)) {
          allMoods.add({'key': mood, 'label': mood});
        }
      }
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allMoods.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAllSelected = selectedMood == null;
            return GestureDetector(
              onTap: () => onMoodSelected(null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isAllSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isAllSelected
                        ? AppColors.primary.withOpacity(0.5)
                        : Theme.of(context).dividerColor.withOpacity(0.05),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    'All',
                    style: TextStyle(
                      color: isAllSelected 
                          ? AppColors.primary 
                          : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: isAllSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }

          final moodData = allMoods[index - 1];
          final moodKey = moodData['key'] ?? '';
          final moodLabel = moodData['label'] ?? '';

          return MoodChip(
            mood: moodKey,
            label: moodLabel,
            isSelected: selectedMood == moodKey,
            onTap: () => onMoodSelected(moodKey),
          );
        },
      ),
    );
  }
}
