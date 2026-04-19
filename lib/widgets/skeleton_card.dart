import 'package:flutter/material.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';

class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final shimmer = AppColors.backgroundElevated.withValues(alpha: _animation.value);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _box(8, 8, shimmer, shape: BoxShape.circle),
                  const SizedBox(width: 8),
                  _box(100, 12, shimmer),
                  const Spacer(),
                  _box(40, 10, shimmer),
                ],
              ),
              const SizedBox(height: 14),
              _box(double.infinity, 12, shimmer),
              const SizedBox(height: 8),
              _box(double.infinity, 12, shimmer),
              const SizedBox(height: 8),
              _box(200, 12, shimmer),
              const SizedBox(height: 16),
              Row(
                children: List.generate(4, (_) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 40,
                    decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _box(double width, double height, Color color,
      {BoxShape shape = BoxShape.rectangle}) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(color: color, shape: shape,
          borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(6) : null),
    );
  }
}
