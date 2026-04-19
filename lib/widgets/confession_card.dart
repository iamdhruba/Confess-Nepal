import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';

// Sensitive keywords that trigger content warning
const _sensitiveKeywords = [
  'suicide', 'self-harm', 'kill myself', 'abuse', 'rape', 'assault',
  'depression', 'overdose', 'cutting',
];

bool _isSensitive(String content) {
  final lower = content.toLowerCase();
  return _sensitiveKeywords.any((k) => lower.contains(k));
}

class ConfessionCard extends StatefulWidget {
  final Confession confession;
  final VoidCallback? onTap;
  final int index;
  final int? rank;

  const ConfessionCard({
    super.key,
    required this.confession,
    this.onTap,
    this.index = 0,
    this.rank,
  });

  @override
  State<ConfessionCard> createState() => _ConfessionCardState();
}

class _ConfessionCardState extends State<ConfessionCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final userReactions = state.getUserReactions(widget.confession.id);
    final moodColor = AppColors.moodColor(widget.confession.mood);
    final sensitive = _isSensitive(widget.confession.content) && !_revealed;
    final isBookmarked = state.isBookmarked(widget.confession.id);

    return Dismissible(
      key: ValueKey('swipe_${widget.confession.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        widget.onTap?.call();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.reply_rounded, color: AppColors.primary, size: 22),
            const SizedBox(height: 4),
            Text('Reply', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: sensitive ? null : widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.moodGradient(widget.confession.mood),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: moodColor.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: moodColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, moodColor, isBookmarked, state),
                    const SizedBox(height: 12),
                    sensitive ? _buildContentWarning(context) : _buildContent(context),
                    const SizedBox(height: 14),
                    _buildReactions(context, state, userReactions),
                    const SizedBox(height: 10),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (widget.index * 80).ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: (widget.index * 80).ms, curve: Curves.easeOutCubic);
  }

  Widget _buildHeader(BuildContext context, Color moodColor, bool isBookmarked, AppState state) {
    return Row(
      children: [
        if (widget.rank != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: widget.rank! <= 3 ? AppColors.primaryGradient : null,
              color: widget.rank! > 3 ? AppColors.backgroundElevated : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '#${widget.rank}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: moodColor, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: moodColor.withOpacity(0.5), blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.confession.anonymousName,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: moodColor.withOpacity(0.9), fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (widget.confession.locationTag != null) ...[
          Icon(Icons.location_on_outlined, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 2),
          Text(widget.confession.locationTag!, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 8),
        ],
        Text(widget.confession.timeAgo, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => state.toggleBookmark(widget.confession.id),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              key: ValueKey(isBookmarked),
              size: 18,
              color: isBookmarked ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentWarning(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _revealed = true),
      child: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Text(
              widget.confession.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary, height: 1.6),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundCard.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    'Sensitive content — tap to reveal',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.warning, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      widget.confession.content,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary, height: 1.6),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildReactions(BuildContext context, AppState state, Set<String> userReactions) {
    final reactions = [
      _ReactionData('relatable', '😭', 'Relatable', AppColors.reactionRelatable),
      _ReactionData('stay_strong', '❤️', 'Stay Strong', AppColors.reactionStayStrong),
      _ReactionData('wtf', '🤯', 'WTF', AppColors.reactionWtf),
      _ReactionData('funny', '😂', 'Funny', AppColors.reactionFunny),
    ];

    final hasReacted = userReactions.isNotEmpty;

    return Row(
      children: reactions.map((r) {
        final count = widget.confession.reactions[r.key] ?? 0;
        final isActive = userReactions.contains(r.key);
        final isDisabled = hasReacted && !isActive;

        return Expanded(
          child: GestureDetector(
            onTap: isDisabled ? null : () => state.addReaction(widget.confession.id, r.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? r.color.withOpacity(0.15)
                    : AppColors.backgroundGlass,
                borderRadius: BorderRadius.circular(12),
                border: isActive
                    ? Border.all(color: r.color.withOpacity(0.3), width: 1)
                    : null,
              ),
              child: Opacity(
                opacity: isDisabled ? 0.3 : 1.0,
                child: Column(
                  children: [
                    Text(r.emoji, style: TextStyle(fontSize: isActive ? 18 : 16)),
                    const SizedBox(height: 2),
                    Text(
                      _formatCount(count),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isActive ? r.color : AppColors.textTertiary,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text('${widget.confession.commentCount} replies',
            style: Theme.of(context).textTheme.labelSmall),
        const Spacer(),
        if (widget.confession.isDisappearing) ...[
          Icon(Icons.timer_outlined, size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text('24h', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.warning)),
          const SizedBox(width: 8),
        ],
        Icon(Icons.swipe_left_rounded, size: 14, color: AppColors.textTertiary.withOpacity(0.5)),
        const SizedBox(width: 3),
        Text('swipe to reply',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary.withOpacity(0.5), fontSize: 9)),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

class _ReactionData {
  final String key;
  final String emoji;
  final String label;
  final Color color;
  _ReactionData(this.key, this.emoji, this.label, this.color);
}
