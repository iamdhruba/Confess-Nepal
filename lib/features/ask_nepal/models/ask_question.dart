class AskQuestion {
  final String id;
  final String authorId;
  final String anonymousName;
  final String question;
  final String? category;
  final DateTime createdAt;
  final int answerCount;
  final int upvotes;

  final bool hasUpvoted;
  final bool isHidden;

  AskQuestion({
    required this.id,
    required this.authorId,
    required this.anonymousName,
    required this.question,
    this.category,
    required this.createdAt,
    this.answerCount = 0,
    this.upvotes = 0,
    this.hasUpvoted = false,
    this.isHidden = false,
  });

  factory AskQuestion.fromMap(Map<String, dynamic> map) {
    return AskQuestion(
      id: map['_id'] ?? map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      anonymousName: map['anonymousName'] ?? '',
      question: map['question'] ?? '',
      category: map['category'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      answerCount: (map['answerCount'] ?? 0) as int,
      upvotes: (map['upvotes'] ?? 0) as int,
      hasUpvoted: map['hasUpvoted'] ?? false,
      isHidden: map['isHidden'] ?? false,
    );
  }

  AskQuestion copyWith({
    String? id,
    String? authorId,
    String? anonymousName,
    String? question,
    String? category,
    DateTime? createdAt,
    int? answerCount,
    int? upvotes,
    bool? hasUpvoted,
    bool? isHidden,
  }) {
    return AskQuestion(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      anonymousName: anonymousName ?? this.anonymousName,
      question: question ?? this.question,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      answerCount: answerCount ?? this.answerCount,
      upvotes: upvotes ?? this.upvotes,
      hasUpvoted: hasUpvoted ?? this.hasUpvoted,
      isHidden: isHidden ?? this.isHidden,
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
