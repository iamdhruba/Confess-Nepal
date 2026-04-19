import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../models/comment.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final int depth;

  const CommentTile({super.key, required this.comment, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: depth == 0
                  ? AppColors.backgroundSecondary
                  : AppColors.backgroundElevated.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: depth > 0
                  ? Border(
                      left: BorderSide(
                          color: AppColors.primary.withOpacity(0.3), width: 2))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      comment.anonymousName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(comment.timeAgo,
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ActionChip(
                        icon: Icons.arrow_upward_rounded,
                        label: '${comment.upvotes}',
                        onTap: () {}),
                    const SizedBox(width: 12),
                    _ActionChip(
                        icon: Icons.reply_rounded, label: 'Reply', onTap: () {}),
                    const SizedBox(width: 12),
                    _ActionChip(
                        icon: Icons.mail_outline_rounded, label: 'DM', onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
          ...comment.replies.map(
            (reply) => CommentTile(comment: reply, depth: depth + 1),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
          begin: 0.05,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  )),
        ],
      ),
    );
  }
}
