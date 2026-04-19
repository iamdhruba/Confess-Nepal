class Confession {
  final String id;
  final String authorId;
  final String anonymousName;
  final String content;
  final String mood;
  final String? locationTag;
  final DateTime createdAt;
  final Map<String, int> reactions;
  final int commentCount;
  final bool isConfessionOfDay;
  final bool isDisappearing;
  final bool isVoice;
  final bool isHidden;
  final List<String> userReactions;
  final int repostCount;
  final int saveCount;
  final bool userSaved;
  final bool userReposted;

  Confession({
    required this.id,
    required this.authorId,
    required this.anonymousName,
    required this.content,
    required this.mood,
    this.locationTag,
    required this.createdAt,
    required this.reactions,
    this.commentCount = 0,
    this.isConfessionOfDay = false,
    this.isDisappearing = false,
    this.isVoice = false,
    this.isHidden = false,
    this.userReactions = const [],
    this.repostCount = 0,
    this.saveCount = 0,
    this.userSaved = false,
    this.userReposted = false,
  });

  factory Confession.fromMap(Map<String, dynamic> map) {
    return Confession(
      id: map['_id'] ?? map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      anonymousName: map['anonymousName'] ?? '',
      content: map['content'] ?? '',
      mood: map['mood'] ?? 'sad',
      locationTag: map['locationTag'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      reactions: map['reactions'] != null
          ? Map<String, int>.from(
              (map['reactions'] as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toInt()),
              ),
            )
          : {'relatable': 0, 'stay_strong': 0, 'wtf': 0, 'funny': 0},
      commentCount: (map['commentCount'] ?? 0) as int,
      isConfessionOfDay: map['isConfessionOfDay'] ?? false,
      isDisappearing: map['isDisappearing'] ?? false,
      isVoice: map['isVoice'] ?? false,
      isHidden: map['isHidden'] ?? false,
      userReactions: map['userReactions'] != null
          ? List<String>.from(map['userReactions'])
          : [],
      repostCount: (map['repostCount'] as num?)?.toInt() ?? 0,
      saveCount: (map['saveCount'] as num?)?.toInt() ?? 0,
      userSaved: map['userSaved'] as bool? ?? false,
      userReposted: map['userReposted'] as bool? ?? false,
    );
  }

  Confession copyWith({
    Map<String, int>? reactions,
    List<String>? userReactions,
    int? commentCount,
    bool? isHidden,
    bool? isConfessionOfDay,
    int? repostCount,
    int? saveCount,
    bool? userSaved,
    bool? userReposted,
  }) {
    return Confession(
      id: id,
      authorId: authorId,
      anonymousName: anonymousName,
      content: content,
      mood: mood,
      locationTag: locationTag,
      createdAt: createdAt,
      reactions: reactions ?? Map.from(this.reactions),
      commentCount: commentCount ?? this.commentCount,
      isConfessionOfDay: isConfessionOfDay ?? this.isConfessionOfDay,
      isDisappearing: isDisappearing,
      isVoice: isVoice,
      isHidden: isHidden ?? this.isHidden,
      userReactions: userReactions ?? List.from(this.userReactions),
      repostCount: repostCount ?? this.repostCount,
      saveCount: saveCount ?? this.saveCount,
      userSaved: userSaved ?? this.userSaved,
      userReposted: userReposted ?? this.userReposted,
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

  int get totalReactions =>
      reactions.values.fold(0, (sum, count) => sum + count);
}
