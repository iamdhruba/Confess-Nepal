import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../../profile/providers/notification_provider.dart';
import '../../profile/models/notification_model.dart';
import 'confession_detail_screen.dart';
import '../../ask_nepal/screens/ask_detail_screen.dart';
import '../../ask_nepal/providers/ask_nepal_provider.dart';
import '../providers/confession_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notifications', 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          if (provider.notifications.isNotEmpty)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: const Text('Mark all as read', 
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: provider.isLoading && provider.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : provider.notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => provider.loadNotifications(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: provider.notifications.length,
                    itemBuilder: (context, index) {
                      final n = provider.notifications[index];
                      return _NotificationTile(notification: n);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, 
                size: 48, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 24),
          const Text('All caught up!',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Reaction and comment notifications for your confessions will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _handleNavigation(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead 
            ? Colors.transparent 
            : (isDark ? AppColors.primary.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.02)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead 
              ? Theme.of(context).dividerColor.withValues(alpha: 0.05)
              : AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: notification.senderName,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(text: notification.message),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      color: isDark ? AppColors.textMuted : AppColors.textTertiaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ).animate().fadeIn().slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'reaction':
        icon = Icons.favorite_rounded;
        color = AppColors.primary;
        break;
      case 'comment':
        icon = Icons.chat_bubble_rounded;
        color = AppColors.accent;
        break;
      case 'upvote':
        icon = Icons.arrow_upward_rounded;
        color = AppColors.primary;
        break;
      case 'answer':
        icon = Icons.forum_rounded;
        color = AppColors.accent;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppColors.textTertiary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  void _handleNavigation(BuildContext context) async {
    context.read<NotificationProvider>().markAsRead(notification.id);

    if (notification.targetModel == 'Confession') {
      try {
        final confession = await context.read<ConfessionProvider>().getConfessionById(notification.targetId);
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConfessionDetailScreen(confession: confession),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error navigating to confession: $e');
      }
    } else if (notification.targetModel == 'Question') {
      try {
        final question = await context.read<AskNepalProvider>().getQuestionById(notification.targetId);
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AskDetailScreen(question: question),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error navigating to question: $e');
      }
    }
  }
}
