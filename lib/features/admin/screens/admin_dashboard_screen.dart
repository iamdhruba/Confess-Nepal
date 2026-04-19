import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/admin_provider.dart';
import '../../ask_nepal/models/ask_question.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStats();
      context.read<AdminProvider>().loadConfessions();
      context.read<AdminProvider>().loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final stats = adminProvider.stats;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('Admin Dashboard',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          backgroundColor: AppColors.backgroundPrimary,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Confessions'),
              Tab(text: 'Ask Nepal'),
            ],
            indicatorColor: AppColors.primary,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                adminProvider.loadStats();
                adminProvider.loadConfessions();
                adminProvider.loadQuestions();
              },
            ),
          ],
        ),
        body: adminProvider.isLoading && stats.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await adminProvider.loadStats();
                  await adminProvider.loadConfessions();
                  await adminProvider.loadQuestions();
                },
                child: TabBarView(
                  children: [
                    _buildConfessionTab(adminProvider, stats),
                    _buildQuestionTab(adminProvider, stats),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildConfessionTab(AdminProvider provider, Map<String, dynamic> stats) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildStatsGrid(stats)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'MANAGE CONFESSIONS',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final val = provider.confessions[index];
              return _buildAdminConfessionCard(val, provider);
            },
            childCount: provider.confessions.length,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionTab(AdminProvider provider, Map<String, dynamic> stats) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildStatsGrid(stats)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'MANAGE QUESTIONS',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final val = provider.questions[index];
              return _buildAdminQuestionCard(val, provider);
            },
            childCount: provider.questions.length,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _buildStatCard('Total Users', stats['users']?.toString() ?? '0', Icons.people_outline),
          _buildStatCard('Confessions', stats['confessions']?.toString() ?? '0', Icons.chat_bubble_outline),
          _buildStatCard('Questions', stats['questions']?.toString() ?? '0', Icons.forum_outlined, color: AppColors.accent),
          _buildStatCard('Total Karma', stats['karma']?.toString() ?? '0', Icons.star_outline),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color ?? AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAdminQuestionCard(AskQuestion q, AdminProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: q.isHidden 
            ? AppColors.error.withValues(alpha: 0.2) 
            : Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(q.anonymousName, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              if (q.isHidden)
                const Text('HIDDEN', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(q.category?.toUpperCase() ?? 'GEN', 
                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(q.question, maxLines: 3, overflow: TextOverflow.ellipsis, 
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildAdminAction(
                label: q.isHidden ? 'Unhide' : 'Hide',
                icon: q.isHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                onTap: () => provider.toggleHideQuestion(q.id),
                color: q.isHidden ? AppColors.success : AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminConfessionCard(dynamic confession, AdminProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: confession.isHidden 
            ? AppColors.error.withValues(alpha: 0.2) 
            : Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(confession.anonymousName, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              if (confession.isHidden)
                const Text('HIDDEN', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
              if (confession.isConfessionOfDay)
                const Icon(Icons.push_pin_rounded, color: AppColors.accent, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Text(confession.content, maxLines: 3, overflow: TextOverflow.ellipsis, 
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildAdminAction(
                label: confession.isConfessionOfDay ? 'Unpin' : 'Pin',
                icon: Icons.push_pin_outlined,
                onTap: () => provider.togglePin(confession.id),
              ),
              const SizedBox(width: 8),
              _buildAdminAction(
                label: confession.isHidden ? 'Unhide' : 'Hide',
                icon: confession.isHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                onTap: () => provider.toggleHide(confession.id),
                color: confession.isHidden ? AppColors.success : AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAction({required String label, required IconData icon, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary, size: 14),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color ?? AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
