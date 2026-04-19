class NotificationModel {
  final String id;
  final String senderName;
  final String type;
  final String message;
  final String targetId;
  final String targetModel;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.senderName,
    required this.type,
    required this.message,
    required this.targetId,
    required this.targetModel,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['_id'] ?? map['id'] ?? '',
      senderName: map['senderName'] ?? 'Someone',
      type: map['type'] ?? 'system',
      message: map['message'] ?? '',
      targetId: map['targetId'] ?? '',
      targetModel: map['targetModel'] ?? 'Confession',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? senderName,
    String? type,
    String? message,
    String? targetId,
    String? targetModel,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      type: type ?? this.type,
      message: message ?? this.message,
      targetId: targetId ?? this.targetId,
      targetModel: targetModel ?? this.targetModel,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
