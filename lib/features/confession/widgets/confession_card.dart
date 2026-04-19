import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../models/confession.dart';
import '../providers/confession_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/screens/auth/login_screen.dart';
import 'share.dart';

class ConfessionCard extends StatelessWidget {
  final Confession confession;
  final VoidCallback? onTap;
  final int index;

  const ConfessionCard({
    super.key,
    required this.confession,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConfessionProvider>();
    final userReactions = confession.userReactions;
    final moodColor = AppColors.moodColor(confession.mood);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, moodColor),
            const SizedBox(height: 14),
            _buildContent(context),
            const SizedBox(height: 20),
            _buildReactions(context, provider, userReactions),
            const SizedBox(height: 18),
            _buildFooter(context),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 80).ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildHeader(BuildContext context, Color moodColor) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                confession.anonymousName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<ConfessionProvider>().setMoodFilter(confession.mood);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: moodColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    confession.mood.toUpperCase(),
                    style: TextStyle(
                      color: moodColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (confession.locationTag != null) ...[
              GestureDetector(
                onTap: () {
                  context.read<ConfessionProvider>().setLocationFilter(confession.locationTag);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_rounded, size: 10, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        confession.locationTag!.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              confession.timeAgo.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 8,
                    letterSpacing: 0.8,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      confession.content,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary.withOpacity(0.95),
            height: 1.6,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
    );
  }

  Widget _buildReactions(
    BuildContext context,
    ConfessionProvider provider,
    List<String> userReactions,
  ) {
    final reactions = [
      _ReactionData('relatable', '😭', 'Relatable', AppColors.reactionRelatable),
      _ReactionData('stay_strong', '❤️', 'Stay Strong', AppColors.reactionStayStrong),
      _ReactionData('wtf', '🤯', 'WTF', AppColors.reactionWtf),
      _ReactionData('funny', '😂', 'Funny', AppColors.reactionFunny),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: reactions.map((r) {
        final count = confession.reactions[r.key] ?? 0;
        final isActive = userReactions.contains(r.key);

        return GestureDetector(
          onTap: () => provider.addReaction(confession.id, r.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
            color: isActive ? r.color.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isActive ? r.color.withOpacity(0.4) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(r.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  _formatCount(count),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isActive ? r.color : AppColors.textSecondary,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.backgroundElevated.withOpacity(0.5)
                  : AppColors.lightElevated,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  '${confession.commentCount} replies',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        if (confession.isDisappearing) ...[
          Icon(Icons.timer_outlined, size: 14, color: AppColors.warning.withOpacity(0.8)),
          const SizedBox(width: 10),
        ],
        // Save
        GestureDetector(
          onTap: () => _requireLogin(context, () => context.read<ConfessionProvider>().toggleSave(confession.id)),
          child: _FooterAction(
            icon: confession.userSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            count: confession.saveCount,
            color: confession.userSaved ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 14),
        // Repost
        GestureDetector(
          onTap: () => _requireLogin(context, () => _handleRepost(context)),
          child: _FooterAction(
            icon: confession.userReposted ? Icons.repeat_on_rounded : Icons.repeat_rounded,
            count: confession.repostCount,
            color: confession.userReposted ? AppColors.accent : AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 14),
        if (confession.isVoice) ...[
          Icon(Icons.mic_none_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 14),
        ],
        // Share
        GestureDetector(
          onTap: () => _showShareSheet(context),
          child: const Icon(Icons.ios_share_rounded, size: 17, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  void _requireLogin(BuildContext context, VoidCallback action) {
    final isLoggedIn = context.read<ProfileProvider>().hasEmail;
    if (!isLoggedIn) {
      _showLoginPrompt(context);
      return;
    }
    action();
  }

  void _showLoginPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔐', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            const Text(
              'Login Required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'You need an account to save or repost confessions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('Login / Sign Up',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    ConfessionShareSheet.show(context, confession);
  }

  Future<void> _handleRepost(BuildContext context) async {
    HapticFeedback.mediumImpact();
    await context.read<ConfessionProvider>().repost(confession.id);
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

class _FooterAction extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  const _FooterAction({required this.icon, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 3),
        Text(
          count > 0 ? (count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count') : '0',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

