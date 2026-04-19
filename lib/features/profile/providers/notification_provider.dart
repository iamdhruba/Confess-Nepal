import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../../../core/network/repositories/notification_repository.dart';
import '../../../core/network/api_client.dart';

class NotificationProvider extends ChangeNotifier {
  final _notificationRepo = NotificationRepository();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    if (!ApiClient.instance.isAuthenticated) return;
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _notificationRepo.getAll();
      _notifications = (data['notifications'] as List)
          .map((n) => NotificationModel.fromMap(n as Map<String, dynamic>))
          .toList();
      _unreadCount = data['unreadCount'] ?? 0;
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // Optimistic update
      _unreadCount = 0;
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        senderName: n.senderName,
        type: n.type,
        message: n.message,
        targetId: n.targetId,
        targetModel: n.targetModel,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      notifyListeners();

      await _notificationRepo.markAllAsRead();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1 && !_notifications[idx].isRead) {
        _unreadCount = (_unreadCount - 1).clamp(0, 999);
        final n = _notifications[idx];
        _notifications[idx] = NotificationModel(
          id: n.id,
          senderName: n.senderName,
          type: n.type,
          message: n.message,
          targetId: n.targetId,
          targetModel: n.targetModel,
          isRead: true,
          createdAt: n.createdAt,
        );
        notifyListeners();
        await _notificationRepo.markAsRead(id);
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }
}
