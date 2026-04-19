import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import 'package:confess_nepal/core/utils/app_alerts.dart';
import '../models/comment.dart';
import '../../../core/network/repositories/comment_repository.dart';
import '../../../core/network/repositories/message_repository.dart';
import '../../../features/profile/providers/profile_provider.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  final int depth;
  final String confessionId;
  final void Function(Comment, String)? onReplyPosted;

  const CommentTile({
    super.key,
    required this.comment,
    required this.confessionId,
    this.depth = 0,
    this.onReplyPosted,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  final _commentRepo = CommentRepository();
  final _messageRepo = MessageRepository();

  int _upvotes = 0;
  bool _hasUpvoted = false;
  bool _showReplyBox = false;
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _upvotes = widget.comment.upvotes;
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _handleUpvote() async {
    final profile = context.read<ProfileProvider>();
    if (!profile.isAuthenticated) {
      _showLoginSnack();
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _hasUpvoted = !_hasUpvoted;
      _upvotes += _hasUpvoted ? 1 : -1;
    });
    try {
      final newCount = await _commentRepo.upvote(widget.comment.id);
      if (mounted) setState(() => _upvotes = newCount);
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasUpvoted = !_hasUpvoted;
          _upvotes += _hasUpvoted ? 1 : -1;
        });
      }
    }
  }

  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    final profile = context.read<ProfileProvider>();
    if (!profile.isAuthenticated) {
      _showLoginSnack();
      return;
    }
    try {
      final comment = await _commentRepo.create(
        confessionId: widget.confessionId,
        content: text,
        parentId: widget.comment.id,
      );
      _replyController.clear();
      setState(() => _showReplyBox = false);
      HapticFeedback.lightImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        AppAlerts.showInfo(context, 'Reply posted');
        widget.onReplyPosted?.call(Comment.fromMap(comment), widget.comment.id);
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, e.toString());
      }
    }
  }

  void _showDMDialog() {
    final profile = context.read<ProfileProvider>();
    if (!profile.isAuthenticated) {
      _showLoginSnack();
      return;
    }
    if (widget.comment.authorId == profile.userId) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      AppAlerts.showWarning(context, 'Login required for this action');
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundSecondary : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.textTertiary : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'DM ${widget.comment.anonymousName}',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Your message will show your anonymous name',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              maxLength: 500,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'Write your message...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                ),
                filled: true,
                fillColor: isDark ? AppColors.backgroundElevated : AppColors.lightElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  Navigator.pop(ctx);
                  try {
                    await _messageRepo.sendDM(
                      toUserId: widget.comment.authorId,
                      content: text,
                      contextConfessionId: widget.confessionId,
                    );
                    if (mounted) {
                      AppAlerts.showInfo(context, 'DM sent to ${widget.comment.anonymousName}');
                    }
                  } catch (e) {
                    if (mounted) {
                      AppAlerts.showError(context, e.toString());
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Send DM', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginSnack() {
    AppAlerts.showWarning(context, 'Login required for this action');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? (widget.depth == 0 ? AppColors.backgroundSecondary : AppColors.backgroundElevated.withValues(alpha: 0.5))
        : (widget.depth == 0 ? Theme.of(context).cardColor : AppColors.lightBorder.withValues(alpha: 0.4));
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final subColor = isDark ? AppColors.textTertiary : AppColors.textTertiaryLight;
    final inputBg = isDark ? AppColors.backgroundElevated : AppColors.lightElevated;

    return Padding(
      padding: EdgeInsets.only(left: widget.depth * 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: widget.depth > 0
                  ? Border(left: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 2))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.comment.anonymousName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(widget.comment.timeAgo,
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 8),
                // Content
                Text(
                  widget.comment.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor, height: 1.5),
                ),
                const SizedBox(height: 10),
                // Actions
                Row(
                  children: [
                    // Upvote
                    GestureDetector(
                      onTap: _handleUpvote,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _hasUpvoted ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: _hasUpvoted ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 14,
                              color: _hasUpvoted ? AppColors.primary : subColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_upvotes',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _hasUpvoted ? AppColors.primary : subColor,
                                    fontWeight: _hasUpvoted ? FontWeight.w700 : FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Reply
                    if (widget.depth == 0)
                      _ActionBtn(
                        icon: Icons.reply_rounded,
                        label: 'Reply',
                        color: _showReplyBox ? AppColors.primary : subColor,
                        onTap: () => setState(() => _showReplyBox = !_showReplyBox),
                      ),
                    if (widget.depth == 0) const SizedBox(width: 8),
                    // DM
                    _ActionBtn(
                      icon: Icons.mail_outline_rounded,
                      label: 'DM',
                      color: subColor,
                      onTap: _showDMDialog,
                    ),
                  ],
                ),
                // Reply input box
                if (_showReplyBox) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: _replyController,
                            autofocus: true,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Reply anonymously...',
                              hintStyle: TextStyle(color: subColor, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _submitReply,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Nested replies
          ...widget.comment.replies.map(
            (reply) => CommentTile(
              comment: reply,
              confessionId: widget.confessionId,
              depth: widget.depth + 1,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
          begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
