import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../providers/confession_provider.dart';
import '../widgets/confession_card.dart';
import 'confession_detail_screen.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Immediate load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfessionProvider>().loadTrending();
      context.read<ConfessionProvider>().loadStats();
    });
    
    // Start real-time polling every 20 seconds (increased to prevent rebuild jitter)
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) {
        context.read<ConfessionProvider>().loadStats();
        // Occasionally refresh the trending list too (less frequent)
        if (timer.tick % 5 == 0) {
          context.read<ConfessionProvider>().loadTrending();
        }
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confessionProvider = context.watch<ConfessionProvider>();
    final trending = confessionProvider.trending;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await confessionProvider.loadTrending();
          await confessionProvider.loadStats();
        },
        child: RepaintBoundary(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                toolbarHeight: 64,
                titleSpacing: 20,
                title: Row(
                  children: [
                    Text(
                      'Trending',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Nepal',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildStatSummary(context, confessionProvider),

            // Location filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _LocationChip(
                      label: 'All Nepal',
                      isSelected: confessionProvider.selectedLocationFilter == null,
                      onTap: () => confessionProvider.setLocationFilter(null),
                    ),
                    ...['Kathmandu', 'Pokhara', 'Lalitpur', 'Bhaktapur', 'Dharan', 'Chitwan']
                        .map((loc) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                                child: _LocationChip(
                                  label: loc,
                                  isSelected: confessionProvider.selectedLocationFilter == loc,
                                  onTap: () => confessionProvider.setLocationFilter(loc),
                                ),
                            )),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            if (confessionProvider.isTrendingLoading && trending.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (trending.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('No trending confessions yet',
                      style: TextStyle(color: AppColors.textTertiary)),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= trending.length) return null;
                    final confession = trending[index];
                    return Stack(
                      children: [
                        ConfessionCard(
                          confession: confession,
                          index: index,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ConfessionDetailScreen(confession: confession),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 10,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient:
                                  index < 3 ? AppColors.primaryGradient : null,
                              color: index >= 3
                                  ? AppColors.backgroundElevated
                                  : null,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Theme.of(context).cardColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '#${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: trending.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildStatSummary(BuildContext context, ConfessionProvider p) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)])
              : LinearGradient(colors: [AppColors.lightElevated, AppColors.lightSurface]),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.primary.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            _TrendingStatItem(
              label: 'Active Now', 
              value: '${p.activeCount}',
              isHighlight: true,
            ),
            _divider(),
            _TrendingStatItem(label: 'Today', value: '${p.todayCount}'),
            _divider(),
            _TrendingStatItem(label: 'Trending', value: '${p.trendingCount}'),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: AppColors.backgroundElevated,
      );
}

class _TrendingStatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _TrendingStatItem({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isHighlight ? AppColors.primary : null,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isHighlight ? AppColors.primary.withOpacity(0.8) : AppColors.textTertiary,
                  fontSize: 9,
                  fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ],
      ).animate(target: isHighlight ? 1 : 0).shimmer(
            duration: 2000.ms,
            color: AppColors.primary.withOpacity(0.1),
          ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LocationChip({required this.label, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
                : Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
