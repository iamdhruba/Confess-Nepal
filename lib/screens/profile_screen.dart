import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../../providers/app_state.dart';
import 'confession_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.backgroundPrimary.withOpacity(0.95),
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            expandedHeight: 70,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Text(
                '👤 My Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Identity card
                  _buildIdentityCard(context, state),
                  const SizedBox(height: 16),

                  // Stats grid
                  _buildStatsGrid(context, state),
                  const SizedBox(height: 16),

                  // Badges section
                  _buildBadgesSection(context, state),
                  const SizedBox(height: 16),

                  // Bookmarks section
                  _buildBookmarksSection(context, state),
                  const SizedBox(height: 16),

                  // Streak section
                  _buildStreakSection(context, state),
                  const SizedBox(height: 16),

                  // Settings list
                  _buildSettingsSection(context),
                  const SizedBox(height: 16),

                  // About section
                  _buildAboutSection(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('🎭', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 14),

          // Username
          Text(
            state.currentUsername,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Your anonymous identity',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 14),

          // Regenerate button
          GestureDetector(
            onTap: () => state.regenerateUsername(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded,
                      size: 16, color: Colors.white.withOpacity(0.9)),
                  const SizedBox(width: 6),
                  Text(
                    'Generate New Identity',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildStatsGrid(BuildContext context, AppState state) {
    return Row(
      children: [
        _StatCard(
          icon: '✨',
          value: '${state.karma}',
          label: 'Karma',
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: '🔥',
          value: '${state.streakDays}',
          label: 'Day Streak',
          color: AppColors.accent,
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: '🏅',
          value: '${state.badges.length}',
          label: 'Badges',
          color: AppColors.moodFunny,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildBadgesSection(BuildContext context, AppState state) {
    final allBadges = [
      {'name': 'Early Confessor', 'icon': '🌅', 'desc': 'Posted within 24h of joining', 'earned': true},
      {'name': 'Night Owl', 'icon': '🦉', 'desc': 'Posted between midnight and 5am', 'earned': true},
      {'name': 'Top Listener', 'icon': '👂', 'desc': 'Left 50+ supportive comments', 'earned': false},
      {'name': 'Streaker', 'icon': '🔥', 'desc': '7-day confession streak', 'earned': false},
      {'name': 'Heart Healer', 'icon': '💜', 'desc': '100 "Stay Strong" reactions given', 'earned': false},
      {'name': 'Viral Voice', 'icon': '📢', 'desc': 'Confession got 1000+ reactions', 'earned': false},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🏅 Badges',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                '${state.badges.length}/${allBadges.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allBadges.map((badge) {
              final earned = badge['earned'] as bool;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: earned
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: earned
                      ? Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      badge['icon'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: earned ? null : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badge['name'] as String,
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: earned
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                                fontWeight: earned
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                    ),
                    if (!earned) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.lock_outline_rounded,
                          size: 10, color: AppColors.textTertiary),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildBookmarksSection(BuildContext context, AppState state) {
    final saved = state.allConfessions
        .where((c) => state.isBookmarked(c.id))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🔖 Saved',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${saved.length}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          if (saved.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('No saved confessions yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
            )
          else
            ...saved.map((c) => GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ConfessionDetailScreen(confession: c))),
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      c.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }

  Widget _buildStreakSection(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 This Week',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((entry) {
              final isActive = entry.key < state.streakDays;
              final isToday = entry.key == state.streakDays - 1;

              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive
                          ? isToday
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3)
                          : AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: isActive
                          ? const Text('✓',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.value,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w400,
                        ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildSettingsSection(BuildContext context) {
    final settings = [
      {'icon': Icons.notifications_outlined, 'label': 'Notifications', 'trailing': 'On'},
      {'icon': Icons.dark_mode_outlined, 'label': 'Dark Mode', 'trailing': 'Always'},
      {'icon': Icons.language_rounded, 'label': 'Language', 'trailing': 'English'},
      {'icon': Icons.shield_outlined, 'label': 'Content Filters', 'trailing': ''},
      {'icon': Icons.info_outline_rounded, 'label': 'About ConfessNepal', 'trailing': ''},
      {'icon': Icons.policy_outlined, 'label': 'Privacy Policy', 'trailing': ''},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '⚙️ Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ...settings.map((s) => ListTile(
                leading: Icon(
                  s['icon'] as IconData,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                title: Text(
                  s['label'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                trailing: (s['trailing'] as String).isNotEmpty
                    ? Text(
                        s['trailing'] as String,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                ),
                      )
                    : Icon(Icons.chevron_right_rounded,
                        color: AppColors.textTertiary, size: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () {},
              )),
          const SizedBox(height: 8),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '🇳🇵',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            'ConfessNepal v1.0',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'A safe space for Nepal to express freely',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Made with ❤️ in Nepal',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
