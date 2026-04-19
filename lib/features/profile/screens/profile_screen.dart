import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../providers/profile_provider.dart';
import '../../confession/providers/confession_provider.dart';
import '../../confession/models/confession.dart';
import '../../confession/screens/confession_detail_screen.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/edit_profile_screen.dart';
import 'change_password_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Confession> _myConfessions = [];
  bool _confessionsLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onTabSelected(_tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _onTabSelected(0));
  }

  void _onTabSelected(int index) {
    if (index == 1) _loadMyConfessions();
    if (index == 2) context.read<ConfessionProvider>().loadSaved();
    if (index == 3) context.read<ConfessionProvider>().loadReposted();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyConfessions() async {
    final p = context.read<ProfileProvider>();
    if (p.userId.isEmpty) return;
    setState(() => _confessionsLoading = true);
    try {
      final data = await context
          .read<ConfessionProvider>()
          .confessionRepo
          .getUserConfessions(p.userId);
      if (mounted) {
        setState(() {
          _myConfessions = (data['confessions'] as List)
              .map((c) => Confession.fromMap(c as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _confessionsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();

    if (p.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(child: _buildHeader(context, p)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Profile'),
                    Tab(text: 'My Post'),
                    Tab(text: 'Saved'),
                    Tab(text: 'Reposted'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildProfileTab(context, p),
              _buildMyConfessionsTab(context),
              _buildSavedTab(context),
              _buildRepostedTab(context),
            ],
          ),
        ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileProvider p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A0A2E) : const Color(0xFFE8E8FF),
            Theme.of(context).scaffoldBackgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('My Profile',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              if (!p.hasEmail) ...[
                _headerBtn(
                  label: 'Login',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
                ),
                const SizedBox(width: 8),
                _headerBtn(
                  label: 'Sign Up',
                  gradient: true,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SignupScreen())),
                ),
              ] else
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: AppColors.textSecondary, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Avatar + name
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Center(
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 36)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.currentUsername,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    if (p.hasEmail) ...[
                      const SizedBox(height: 2),
                      Text(p.email,
                          style: const TextStyle(
                              color: AppColors.textTertiary, fontSize: 12)),
                    ],
                    if (p.bio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(p.bio,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _statItem(context, '${p.karma}', 'Karma', AppColors.primary),
              _divider(),
              _statItem(context, '${p.streakDays}', 'Streak', AppColors.accent),
              _divider(),
              _statItem(context, '${p.totalConfessions}', 'Posts', AppColors.moodDark),
              _divider(),
              _statItem(context, '${p.badges.length}', 'Badges', AppColors.moodFunny),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, ProfileProvider p) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        _buildBadgesSection(context, p),
        const SizedBox(height: 16),
        _buildStreakSection(context, p),
        const SizedBox(height: 16),
        _buildSettingsSection(context, p),
        const SizedBox(height: 16),
        _buildAboutSection(context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSavedTab(BuildContext context) {
    final cp = context.watch<ConfessionProvider>();
    if (cp.isLoading && cp.saved.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (cp.saved.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.bookmark_border_rounded,
        title: 'No saved confessions',
        subtitle: 'Confessions you save will appear here',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => cp.loadSaved(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: cp.saved.length,
        itemBuilder: (context, index) {
          final c = cp.saved[index];
          return _ConfessionMiniCard(
            confession: c,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ConfessionDetailScreen(confession: c)),
            ),
            showDelete: false,
          );
        },
      ),
    );
  }

  Widget _buildRepostedTab(BuildContext context) {
    final cp = context.watch<ConfessionProvider>();
    if (cp.isLoading && cp.reposted.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (cp.reposted.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.repeat_rounded,
        title: 'No reposts yet',
        subtitle: 'Confessions you repost will appear here',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => cp.loadReposted(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: cp.reposted.length,
        itemBuilder: (context, index) {
          final c = cp.reposted[index];
          return _ConfessionMiniCard(
            confession: c,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ConfessionDetailScreen(confession: c)),
            ),
            showDelete: false,
          );
        },
      ),
    );
  }

  Widget _buildEmptyTab({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildMyConfessionsTab(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    if (_confessionsLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Filter out anonymous confessions for anonymous users as requested:
    // "if not signed up, my confessions should be deleted/hidden"
    final visibleConfessions = p.hasEmail 
        ? _myConfessions 
        : _myConfessions.where((c) => !c.isDisappearing).toList();

    if (visibleConfessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notes_rounded, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(p.hasEmail ? 'No confessions yet' : 'Login to save history',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(p.hasEmail 
                  ? 'Your posted confessions will appear here'
                  : 'Anonymous 24h stories are ephemeral and vanish from your profile unless you have an account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 13, height: 1.5)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadMyConfessions,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: visibleConfessions.length,
        itemBuilder: (context, index) {
          final c = visibleConfessions[index];
          return _ConfessionMiniCard(
            confession: c,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ConfessionDetailScreen(confession: c)),
            ),
            onDelete: () async {
              await context.read<ConfessionProvider>().deleteConfession(c.id);
              setState(() => _myConfessions.removeAt(index));
            },
          );
        },
      ),
    );
  }

  Widget _buildBadgesSection(BuildContext context, ProfileProvider p) {
    final allBadges = [
      {'name': 'Early Confessor'},
      {'name': 'Night Owl'},
      {'name': 'Top Listener'},
      {'name': 'Streaker'},
      {'name': 'Karma King'},
      {'name': 'Viral Voice'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Badges',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${p.badges.length}/${allBadges.length}',
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allBadges.map((badge) {
              final earned = p.badges.contains(badge['name']);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: earned
                      ? AppColors.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: earned
                      ? Border.all(
                          color: AppColors.primary.withOpacity(0.3))
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(badge['name']!,
                        style: TextStyle(
                            color: earned
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            fontSize: 12,
                            fontWeight: earned
                                ? FontWeight.w600
                                : FontWeight.w400)),
                    if (!earned) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.lock_outline_rounded,
                          size: 10, color: AppColors.textTertiary),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildStreakSection(BuildContext context, ProfileProvider p) {
    final now = DateTime.now();
    final today = now.weekday - 1; // 0 (Mon) to 6 (Sun)
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('This Week',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              _statChip(context, '${p.streakDays}d Streak', AppColors.primary),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.asMap().entries.map((e) {
              final dayIndex = e.key;
              final isToday = dayIndex == today;
              
              // Logic: Fill the dot if it's within the streak count counting backwards from today
              // Example: Today is Wed (2), Streak is 3 -> Mon (0), Tue (1), Wed (2) are lit.
              final isLit = dayIndex <= today && (today - dayIndex) < p.streakDays;

              return Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isLit
                          ? isToday
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.25)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: isToday
                          ? Border.all(color: AppColors.primary, width: 2)
                          : Border.all(
                              color: isLit ? Colors.transparent : Theme.of(context).dividerColor.withOpacity(0.1),
                              width: 1),
                      boxShadow: isToday && isLit
                          ? [
                              BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ]
                          : [],
                    ),
                    child: Center(
                      child: isLit
                          ? Icon(
                              isToday ? Icons.check_rounded : Icons.check_rounded,
                              color: isToday ? Colors.white : AppColors.primary,
                              size: 18,
                            )
                          : Text(
                              e.value,
                              style: TextStyle(
                                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isToday ? 'Today' : e.value,
                    style: TextStyle(
                        color: isToday
                            ? AppColors.primary
                            : isLit ? AppColors.textPrimary : AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: isToday || isLit ? FontWeight.w700 : FontWeight.w400),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _statChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, ProfileProvider p) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Settings',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
          if (p.isAdmin)
            _settingsTile(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Admin Portal',
              iconColor: AppColors.accent,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
            ),
          _settingsTile(
            icon: Icons.dark_mode_outlined,
            label: 'Dark Mode',
            trailing: Switch(
              value: p.themeMode == ThemeMode.dark,
              onChanged: (_) => p.toggleTheme(),
              activeThumbColor: AppColors.primary,
            ),
          ),
          if (p.hasEmail)
            _settingsTile(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen())),
            ),
          if (p.hasEmail)
            _settingsTile(
              icon: Icons.lock_outline_rounded,
              label: 'Change Password',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen())),
            ),
          if (p.hasEmail)
            _settingsTile(
              icon: Icons.logout_rounded,
              label: 'Logout',
              labelColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () => _confirmLogout(context, p),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Column(
        children: [
          Icon(Icons.location_city_rounded, size: 36, color: AppColors.primary),
          SizedBox(height: 12),
          Text('ConfessNepal v1.0',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('A safe space to express freely',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
              textAlign: TextAlign.center),
          SizedBox(height: 12),
          Text('Made for Nepal',
              style: TextStyle(color: AppColors.accent, fontSize: 12)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  void _confirmLogout(BuildContext context, ProfileProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Logout?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
            'You will continue as an anonymous user.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await p.logout();
            },
            child: const Text('Logout',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _headerBtn({
    required String label,
    required VoidCallback onTap,
    bool gradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient ? AppColors.primaryGradient : null,
          color: gradient ? null : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: gradient
              ? null
              : Border.all(
                  color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                color: gradient ? Colors.white : AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _statItem(
      BuildContext context, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 32, color: Theme.of(context).dividerColor.withOpacity(0.1));

  Widget _settingsTile({
    required IconData icon,
    required String label,
    Color? labelColor,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: iconColor ?? AppColors.textSecondary, size: 20),
      title: Text(label,
          style: TextStyle(
              color: labelColor ?? AppColors.textPrimary, fontSize: 14)),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary, size: 20)
              : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

class _ConfessionMiniCard extends StatelessWidget {
  final Confession confession;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool showDelete;

  const _ConfessionMiniCard({
    required this.confession,
    required this.onTap,
    this.onDelete,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final moodColor = AppColors.moodColor(confession.mood);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: moodColor.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: moodColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(confession.mood.toUpperCase(),
                    style: TextStyle(
                        color: moodColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                const Spacer(),
                Text(confession.timeAgo,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11)),
                const SizedBox(width: 8),
                if (showDelete)
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(confession.content,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text('${confession.commentCount}',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.favorite_border_rounded,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text('${confession.totalReactions}',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Delete confession?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('This cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (onDelete != null) onDelete!();
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
