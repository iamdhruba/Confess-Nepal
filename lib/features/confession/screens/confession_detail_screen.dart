import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../models/confession.dart';
import '../models/comment.dart';
import '../providers/confession_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../widgets/comment_tile.dart';
import '../widgets/share.dart';

class ConfessionDetailScreen extends StatefulWidget {
  final Confession confession;

  const ConfessionDetailScreen({super.key, required this.confession});

  @override
  State<ConfessionDetailScreen> createState() => _ConfessionDetailScreenState();
}

class _ConfessionDetailScreenState extends State<ConfessionDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  List<Comment> _comments = [];
  bool _commentsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final comments = await context
        .read<ConfessionProvider>()
        .getComments(widget.confession.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _commentsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confessionProvider = context.watch<ConfessionProvider>();

    // Use the live version from provider if available (reactions may have updated)
    final confession = confessionProvider.confessions
            .where((c) => c.id == widget.confession.id)
            .firstOrNull ??
        widget.confession;

    final moodColor = AppColors.moodColor(confession.mood);
    final userReactions = confession.userReactions;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [moodColor.withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary, size: 20),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => _showReportSheet(context, confessionProvider),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flag_outlined,
                          color: AppColors.textTertiary, size: 20),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ConfessionShareSheet.show(context, confession),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.share_outlined,
                          color: AppColors.textTertiary, size: 20),
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: moodColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: moodColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppColors.moodEmoji(confession.mood),
                                    style: const TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  confession.mood.toUpperCase(),
                                  style: TextStyle(
                                    color: moodColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(confession.timeAgo,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                moodColor.withOpacity(0.3),
                                moodColor.withOpacity(0.1),
                              ]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                confession.anonymousName.isNotEmpty
                                    ? confession.anonymousName[0].toUpperCase()
                                    : '?',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: moodColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(confession.anonymousName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              if (confession.locationTag != null)
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 12,
                                        color: AppColors.textTertiary),
                                    const SizedBox(width: 2),
                                    Text(confession.locationTag!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                      const SizedBox(height: 20),

                      Text(
                        confession.content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              height: 1.7,
                            ),
                      ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                      const SizedBox(height: 24),

                      _buildReactionsSection(
                          context, confessionProvider, confession, userReactions),
                      const SizedBox(height: 24),

                      Container(height: 1, color: AppColors.backgroundElevated),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Text('💬 Anonymous Replies',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${confession.commentCount}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                        ],
                      ),

                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            const Text('💚', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Be supportive — this person trusted us with their truth',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.success
                                          .withOpacity(0.8),
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _commentsLoading
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= _comments.length) return null;
                            return CommentTile(comment: _comments[index]);
                          },
                          childCount: _comments.length,
                        ),
                      ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCommentInput(context, confessionProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionsSection(
    BuildContext context,
    ConfessionProvider provider,
    Confession confession,
    List<String> userReactions,
  ) {
    final reactions = [
      {'key': 'relatable', 'emoji': '😭', 'label': 'Relatable', 'color': AppColors.reactionRelatable},
      {'key': 'stay_strong', 'emoji': '❤️', 'label': 'Stay Strong', 'color': AppColors.reactionStayStrong},
      {'key': 'wtf', 'emoji': '🤯', 'label': 'WTF', 'color': AppColors.reactionWtf},
      {'key': 'funny', 'emoji': '😂', 'label': 'Funny', 'color': AppColors.reactionFunny},
    ];

    return Row(
      children: reactions.map((r) {
        final key = r['key'] as String;
        final count = confession.reactions[key] ?? 0;
        final isActive = userReactions.contains(key);
        final color = r['color'] as Color;

        return Expanded(
          child: GestureDetector(
            onTap: () async {
              final delta = await provider.addReaction(confession.id, key);
              if (mounted && delta > 0) {
                context.read<ProfileProvider>().addKarma(delta);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? color.withOpacity(0.15)
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(14),
                border: isActive
                    ? Border.all(color: color.withOpacity(0.3))
                    : null,
              ),
              child: Column(
                children: [
                  Text(r['emoji'] as String,
                      style: TextStyle(fontSize: isActive ? 22 : 20)),
                  const SizedBox(height: 4),
                  Text(
                    _formatCount(count),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isActive ? color : AppColors.textSecondary,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r['label'] as String,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? color.withOpacity(0.7)
                              : AppColors.textTertiary,
                          fontSize: 9,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildCommentInput(
      BuildContext context, ConfessionProvider provider) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundPrimary.withOpacity(0.9),
            border: Border(
              top: BorderSide(
                  color: AppColors.backgroundElevated.withOpacity(0.5)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocus,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                    decoration: InputDecoration(
                      hintText: 'Reply anonymously...',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final text = _commentController.text.trim();
                  if (text.isEmpty) return;
                  _commentController.clear();
                  _commentFocus.unfocus();
                  await provider.addComment(
                    confessionId: widget.confession.id,
                    content: text,
                  );
                  await _loadComments();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Reply posted anonymously 💭'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportSheet(
      BuildContext context, ConfessionProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Report Content',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...[
              'Inappropriate content',
              'Harassment / Bullying',
              'Self-harm / Suicide',
              'Spam / Fake',
              'Other',
            ].map((reason) => ListTile(
                  title: Text(reason,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          )),
                  onTap: () async {
                    Navigator.pop(context);
                    await provider.report(
                      targetType: 'confession',
                      targetId: widget.confession.id,
                      reason: reason,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Report submitted. Thank you 💜'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}
