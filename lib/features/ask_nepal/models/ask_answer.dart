class AskAnswer {
  final String id;
  final String questionId;
  final String authorId;
  final String anonymousName;
  final String content;
  final DateTime createdAt;

  AskAnswer({
    required this.id,
    required this.questionId,
    required this.authorId,
    required this.anonymousName,
    required this.content,
    required this.createdAt,
  });

  factory AskAnswer.fromMap(Map<String, dynamic> map) {
    return AskAnswer(
      id: map['_id'] ?? map['id'] ?? '',
      questionId: map['questionId'] ?? '',
      authorId: map['authorId'] ?? '',
      anonymousName: map['anonymousName'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
