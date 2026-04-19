import 'package:uuid/uuid.dart';

class Confession {
  final String id;
  final String anonymousName;
  final String content;
  final String mood; // sad, love, funny, dark, confused
  final String? locationTag;
  final DateTime createdAt;
  final Map<String, int> reactions; // relatable, stay_strong, wtf, funny
  final int commentCount;
  final bool isConfessionOfDay;
  final bool isDisappearing;
  final bool isVoice;
  final bool isExpanded;

  Confession({
    String? id,
    required this.anonymousName,
    required this.content,
    required this.mood,
    this.locationTag,
    DateTime? createdAt,
    Map<String, int>? reactions,
    this.commentCount = 0,
    this.isConfessionOfDay = false,
    this.isDisappearing = false,
    this.isVoice = false,
    this.isExpanded = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        reactions = reactions ??
            {
              'relatable': 0,
              'stay_strong': 0,
              'wtf': 0,
              'funny': 0,
            };

  Confession copyWith({
    String? id,
    String? anonymousName,
    String? content,
    String? mood,
    String? locationTag,
    DateTime? createdAt,
    Map<String, int>? reactions,
    int? commentCount,
    bool? isConfessionOfDay,
    bool? isDisappearing,
    bool? isVoice,
    bool? isExpanded,
  }) {
    return Confession(
      id: id ?? this.id,
      anonymousName: anonymousName ?? this.anonymousName,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      locationTag: locationTag ?? this.locationTag,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? Map.from(this.reactions),
      commentCount: commentCount ?? this.commentCount,
      isConfessionOfDay: isConfessionOfDay ?? this.isConfessionOfDay,
      isDisappearing: isDisappearing ?? this.isDisappearing,
      isVoice: isVoice ?? this.isVoice,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  int get totalReactions =>
      reactions.values.fold(0, (sum, count) => sum + count);
}

class Comment {
  final String id;
  final String confessionId;
  final String anonymousName;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final int upvotes;
  final List<Comment> replies;

  Comment({
    String? id,
    required this.confessionId,
    required this.anonymousName,
    required this.content,
    DateTime? createdAt,
    this.parentId,
    this.upvotes = 0,
    List<Comment>? replies,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        replies = replies ?? [];

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

class AskQuestion {
  final String id;
  final String anonymousName;
  final String question;
  final String? category;
  final DateTime createdAt;
  final int answerCount;
  final int upvotes;

  AskQuestion({
    String? id,
    required this.anonymousName,
    required this.question,
    this.category,
    DateTime? createdAt,
    this.answerCount = 0,
    this.upvotes = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
