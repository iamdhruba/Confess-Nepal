import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../models/ask_question.dart';
import '../models/ask_answer.dart';
import '../providers/ask_nepal_provider.dart';
import '../../profile/providers/profile_provider.dart';

class AskDetailScreen extends StatefulWidget {
  final AskQuestion question;

  const AskDetailScreen({super.key, required this.question});

  @override
  State<AskDetailScreen> createState() => _AskDetailScreenState();
}

class _AskDetailScreenState extends State<AskDetailScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AskNepalProvider>().loadAnswers(widget.question.id);
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final askProvider = context.watch<AskNepalProvider>();
    final q = askProvider.questions.firstWhere((element) => element.id == widget.question.id, orElse: () => widget.question);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Question', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildQuestionCard(q),
                const SizedBox(height: 24),
                const Text('REPLIES',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    )),
                const SizedBox(height: 12),
                if (askProvider.isLoading && askProvider.answers.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ))
                else if (askProvider.answers.isEmpty)
                  _buildReplyPlaceholder()
                else
                  ...askProvider.answers.map((a) => _buildReplyTile(a)).toList(),
              ],
            ),
          ),
          _buildReplyInput(q),
        ],
      ),
    );
  }

  Widget _buildReplyTile(AskAnswer answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(answer.anonymousName, 
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(answer.timeAgo, 
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Text(answer.content, 
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildQuestionCard(AskQuestion q) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  q.category?.toUpperCase() ?? 'GENERAL',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(q.timeAgo.toUpperCase(),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            q.question,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(q.anonymousName, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.read<AskNepalProvider>().upvoteQuestion(q.id),
                child: _actionItem(
                  Icons.arrow_upward_rounded, 
                  '${q.upvotes}', 
                  q.hasUpvoted ? AppColors.primary : AppColors.textTertiary,
                  filled: q.hasUpvoted,
                ),
              ),
              const SizedBox(width: 16),
              _actionItem(Icons.chat_bubble_outline_rounded, '${q.answerCount}', AppColors.accent, filled: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String value, Color color, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: filled ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReplyPlaceholder() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.forum_outlined, size: 48, color: AppColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No replies yet', style: TextStyle(color: AppColors.textTertiary)),
          const Text('Be the first to answer!', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildReplyInput(AskQuestion q) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _answerController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Add an anonymous reply...',
                hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          if (_isSubmitting)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
          else
            GestureDetector(
              onTap: () async {
                if (_answerController.text.trim().isEmpty) return;
                setState(() => _isSubmitting = true);
                try {
                  await context.read<AskNepalProvider>().addAnswer(q.id, _answerController.text.trim());
                  _answerController.clear();
                  FocusScope.of(context).unfocus();
                } catch (_) {} finally {
                  if (mounted) setState(() => _isSubmitting = false);
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
