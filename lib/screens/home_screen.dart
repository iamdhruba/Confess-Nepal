import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../../providers/app_state.dart';
import '../../widgets/confession_card.dart';
import '../../widgets/confession_of_day.dart';
import '../../widgets/mood_chip.dart';
import '../../widgets/streak_widget.dart';
import '../../widgets/night_mode_banner.dart';
import '../../widgets/skeleton_card.dart';
import 'confession_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showHeader = true;
  bool _isLoading = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  void _onScroll() {
    final show = _scrollController.offset < 100;
    if (show != _showHeader) {
      setState(() => _showHeader = show);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Auto-dismiss skeleton as soon as data is available
    if (_isLoading && state.confessions.isNotEmpty) {
      _isLoading = false;
    }
    final allConfessions = state.confessions;
    final confessions = _searchQuery.isEmpty
        ? allConfessions
        : allConfessions
            .where((c) =>
                c.content.toLowerCase().contains(_searchQuery) ||
                c.anonymousName.toLowerCase().contains(_searchQuery))
            .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        backgroundColor: AppColors.backgroundCard,
        displacement: 60,
        child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // Custom App Bar
          _buildSliverAppBar(context, state),

          // Search bar
          if (_isSearching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search confessions...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.backgroundSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _searchController.clear(),
                            child: Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),

          // Night mode banner
          const SliverToBoxAdapter(child: NightModeBanner()),

          // Streak widget
          SliverToBoxAdapter(
            child: StreakWidget(streakDays: state.streakDays, karma: state.karma),
          ),

          // Skeleton loading
          if (_isLoading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const SkeletonCard(),
                childCount: 4,
              ),
            )
          else ...[
            // Confession of the Day
            if (state.confessionOfDay != null)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                      child: Text(
                        '🏆 Today\'s Top Confession',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    ConfessionOfDayCard(
                      confession: state.confessionOfDay!,
                      onTap: () => _openDetail(context, state.confessionOfDay!),
                    ),
                  ],
                ),
              ),

            // Mood Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: MoodFilterBar(
                  selectedMood: state.selectedMoodFilter,
                  onMoodSelected: (mood) => state.setMoodFilter(mood),
                ),
              ),
            ),

            // Section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Row(
                  children: [
                    Text(
                      _searchQuery.isNotEmpty
                          ? '🔍 "$_searchQuery" — ${confessions.length} results'
                          : state.selectedMoodFilter != null
                              ? '${AppColors.moodEmoji(state.selectedMoodFilter!)} ${state.selectedMoodFilter!.toUpperCase()} Confessions'
                              : '💭 Latest Confessions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (_searchQuery.isEmpty)
                      Text('${confessions.length} posts',
                          style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),

            // Confession feed
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= confessions.length) return null;
                  final confession = confessions[index];
                  return ConfessionCard(
                    confession: confession,
                    index: index,
                    onTap: () => _openDetail(context, confession),
                  );
                },
                childCount: confessions.length,
              ),
            ),

            // Pagination indicator
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    confessions.isEmpty ? 'No confessions found' : '— end of feed —',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, AppState state) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Text(
            'Confess',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
            child: Text(
              'Nepal',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
      actions: [
        // Theme toggle
        GestureDetector(
          onTap: () => state.toggleTheme(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.backgroundSecondary
                  : AppColors.lightElevated,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              state.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 18,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Search icon
        GestureDetector(
          onTap: () => setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) _searchController.clear();
          }),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _isSearching
                  ? AppColors.primary.withOpacity(0.15)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.backgroundSecondary
                      : AppColors.lightElevated),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              size: 18,
              color: _isSearching
                  ? AppColors.primary
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Notification bell
        GestureDetector(
          onTap: () => _showNotifications(context),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.backgroundSecondary
                  : AppColors.lightElevated,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Positioned(
                  top: 6, right: 8,
                  child: Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    final notifications = [
      {'icon': '😭', 'text': 'SilentPanda reacted Relatable to your confession', 'time': '2m ago', 'unread': true},
      {'icon': '❤️', 'text': 'MysticFox reacted Stay Strong to your confession', 'time': '15m ago', 'unread': true},
      {'icon': '💬', 'text': 'GhostOwl replied to your confession', 'time': '1h ago', 'unread': true},
      {'icon': '🔥', 'text': 'Your confession is trending in Kathmandu', 'time': '3h ago', 'unread': false},
      {'icon': '🏅', 'text': 'You earned the Night Owl badge', 'time': '1d ago', 'unread': false},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text('Notifications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('Mark all read',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          ...notifications.map((n) => ListTile(
                dense: true,
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: n['unread'] as bool
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(n['icon'] as String, style: const TextStyle(fontSize: 16))),
                ),
                title: Text(
                  n['text'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: n['unread'] as bool ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: n['unread'] as bool ? FontWeight.w500 : FontWeight.w400,
                      ),
                  maxLines: 2,
                ),
                trailing: Text(n['time'] as String,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
              )),
          const SizedBox(height: 16),
        ],
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
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}
