class Comment {
  final String id;
  final String confessionId;
  final String authorId;
  final String anonymousName;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final int upvotes;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.confessionId,
    required this.authorId,
    required this.anonymousName,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.upvotes = 0,
    this.replies = const [],
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['_id'] ?? map['id'] ?? '',
      confessionId: map['confessionId'] ?? '',
      authorId: map['authorId'] ?? '',
      anonymousName: map['anonymousName'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      parentId: map['parentId'],
      upvotes: (map['upvotes'] ?? 0) as int,
      replies: map['replies'] != null
          ? (map['replies'] as List)
              .map((r) => Comment.fromMap(r as Map<String, dynamic>))
              .toList()
          : [],
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
