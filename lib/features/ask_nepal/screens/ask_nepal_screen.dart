import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import 'package:confess_nepal/core/utils/app_alerts.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/ask_nepal_provider.dart';
import 'ask_detail_screen.dart';
import '../../../features/profile/providers/profile_provider.dart';

class AskNepalScreen extends StatefulWidget {
  const AskNepalScreen({super.key});

  @override
  State<AskNepalScreen> createState() => _AskNepalScreenState();
}

class _AskNepalScreenState extends State<AskNepalScreen> {
  final TextEditingController _questionController = TextEditingController();
  String _selectedCategory = 'Deep';

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final askProvider = context.watch<AskNepalProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            toolbarHeight: 64,
            titleSpacing: 20,
            title: Text(
              'Ask Nepal',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? const LinearGradient(colors: [Color(0xFF1E1E2E), Color(0xFF252540)])
                    : LinearGradient(colors: [AppColors.lightElevated, Color(0xFFE8E8FF)]),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ask anything anonymously',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _questionController,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'What would you like to ask Nepal?',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.textTertiary
                                : AppColors.textTertiaryLight,
                          ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: AppConstants.questionCategories
                                .map((cat) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: GestureDetector(
                                        onTap: () =>
                                            setState(() => _selectedCategory = cat),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: _selectedCategory == cat
                                                ? AppColors.primary.withValues(alpha: 0.15)
                                                : Theme.of(context).colorScheme.surface,
                                            borderRadius: BorderRadius.circular(100),
                                            border: Border.all(
                                              color: _selectedCategory == cat
                                                  ? AppColors.primary.withValues(alpha: 0.4)
                                                  : Colors.transparent,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              cat,
                                              style: TextStyle(
                                                color: _selectedCategory == cat
                                                    ? AppColors.primary
                                                    : AppColors.textTertiary,
                                                fontSize: 12,
                                                fontWeight: _selectedCategory == cat
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          if (_questionController.text.trim().length >=
                              AppConstants.minQuestionChars) {
                            if (!context.mounted) return;
                            final profileProvider = context.read<ProfileProvider>();
                            final karmaDelta = await askProvider.addQuestion(
                              _questionController.text.trim(),
                              _selectedCategory,
                            );
                            if (!context.mounted) return;
                            profileProvider.addKarma(karmaDelta);
                            _questionController.clear();
                            AppAlerts.showInfo(context, 'Question posted');
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Popular Questions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
            ),
          ),

          if (askProvider.isLoading && askProvider.questions.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (askProvider.error != null && askProvider.questions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    const Text('Cannot reach server',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => askProvider.loadQuestions(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text('Retry', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= askProvider.questions.length) return null;
                final q = askProvider.questions[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AskDetailScreen(question: q),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
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
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.textMuted : AppColors.textTertiaryLight,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          q.question,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 12, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textTertiary : AppColors.textTertiaryLight),
                            const SizedBox(width: 4),
                            Text(q.anonymousName,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontSize: 11,
                                    )),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                context.read<AskNepalProvider>().upvoteQuestion(q.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.arrow_upward_rounded,
                                        size: 14, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text('${q.upvotes}',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded,
                                      size: 14, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondary : AppColors.textSecondaryLight),
                                  const SizedBox(width: 4),
                                  Text('${q.answerCount}',
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (index * 80).ms)
                    .slideY(begin: 0.08, end: 0, duration: 400.ms);
              },
              childCount: askProvider.questions.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
