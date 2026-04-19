import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../providers/confession_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/profile/providers/notification_provider.dart';
import '../widgets/confession_card.dart';
import '../widgets/confession_of_day.dart';
import '../widgets/mood_chip.dart';
import '../widgets/streak_widget.dart';
import '../widgets/night_mode_banner.dart';
import 'confession_detail_screen.dart';
import 'search_screen.dart';
import '../../../core/constants/app_constants.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    final confessionProvider = context.read<ConfessionProvider>();
    confessionProvider.loadLocations();
    confessionProvider.loadMoods();
    // Wait for ProfileProvider to finish init before loading notifications
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.isLoading) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return profileProvider.isLoading;
      });
    }
    if (!mounted) return;
    final notificationProvider = context.read<NotificationProvider>();
    notificationProvider.loadNotifications();
  }

  void _onScroll() {
    final provider = context.read<ConfessionProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!provider.isLoading && provider.hasMore) {
        provider.loadFeed();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confessionProvider = context.watch<ConfessionProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => confessionProvider.loadFeed(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App bar — use SliverAppBar with a fixed title widget, no Spacer inside FlexibleSpaceBar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 64,
              title: Row(
                children: [
                  Text(
                    'Confess',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                    child: const Text(
                      'Nepal',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Consumer<NotificationProvider>(
                    builder: (context, notifP, _) => _AppBarBtn(
                      icon: Icons.notifications_none_rounded,
                      isDark: isDark,
                      badge: notifP.unreadCount > 0 ? notifP.unreadCount : null,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _AppBarBtn(
                    icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    isDark: isDark,
                    onTap: () => profileProvider.toggleTheme(),
                  ),
                  const SizedBox(width: 8),
                  _AppBarBtn(
                    icon: Icons.search_rounded,
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                  ),
                ],
              ),
              titleSpacing: 20,
            ),

            const SliverToBoxAdapter(child: NightModeBanner()),

            SliverToBoxAdapter(
              child: StreakWidget(
                streakDays: profileProvider.streakDays,
                karma: profileProvider.karma,
              ),
            ),

            if (confessionProvider.confessionOfDay != null)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                      child: Text(
                        'Today\'s Top Confession',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    ConfessionOfDayCard(
                      confession: confessionProvider.confessionOfDay!,
                      onTap: () =>
                          _openDetail(context, confessionProvider.confessionOfDay!),
                    ),
                  ],
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: MoodFilterBar(
                  selectedMood: confessionProvider.selectedMoodFilter,
                  onMoodSelected: confessionProvider.setMoodFilter,
                  dynamicMoods: confessionProvider.dynamicMoods,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: _buildLocationFilter(context, confessionProvider),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        confessionProvider.selectedMoodFilter != null
                            ? '${confessionProvider.selectedMoodFilter!.toUpperCase()} Confessions'
                            : 'Latest Confessions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    Text(
                      '${confessionProvider.confessions.length} posts',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            if (confessionProvider.isLoading && confessionProvider.confessions.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (confessionProvider.error != null && confessionProvider.confessions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📡', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text('Cannot reach server',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      const Text('Make sure the backend is running',
                          style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => confessionProvider.loadFeed(refresh: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Retry', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final confession = confessionProvider.confessions[index];
                    return RepaintBoundary(
                      child: ConfessionCard(
                        confession: confession,
                        index: index,
                        onTap: () => _openDetail(context, confession),
                      ),
                    );
                  },
                  childCount: confessionProvider.confessions.length,
                ),
              ),
              if (confessionProvider.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2),
                    ),
                  ),
                ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, dynamic confession) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ConfessionDetailScreen(confession: confession),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Widget _buildLocationFilter(BuildContext context, ConfessionProvider provider) {
    final allLocations = Set<String>.from(AppConstants.locations);
    allLocations.addAll(provider.dynamicLocations);
    final sortedLocations = allLocations.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text('EXPLORE BY LOCATION',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  )),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: sortedLocations.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final loc = sortedLocations[index];
              final isSelected = provider.selectedLocationFilter == loc;

              return GestureDetector(
                onTap: () => provider.setLocationFilter(loc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).dividerColor.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      loc,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final int? badge;

  const _AppBarBtn({
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundSecondary : AppColors.lightElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            ),
          ),
          if (badge != null && badge! > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    badge! > 9 ? '9+' : '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
