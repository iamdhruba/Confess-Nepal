import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../utils/username_generator.dart';

class AppState extends ChangeNotifier {
  // User state
  String _currentUsername = UsernameGenerator.generate();
  int _streakDays = 3;
  int _karma = 127;
  final Set<String> _badges = {'Early Confessor', 'Night Owl'};

  // Theme state
  ThemeMode _themeMode = ThemeMode.dark;

  // Getters
  ThemeMode get themeMode => _themeMode;

  // Feed state
  final List<Confession> _confessions = List.from(MockData.confessions);
  String? _selectedMoodFilter;
  String? _selectedLocationFilter;
  final Set<String> _expandedConfessions = {};
  final Map<String, Set<String>> _userReactions = {};

  // Questions state
  final List<AskQuestion> _questions = List.from(MockData.questions);

  // Bookmarks
  final Set<String> _bookmarks = {};

  // Getters
  String get currentUsername => _currentUsername;
  int get streakDays => _streakDays;
  int get karma => _karma;
  Set<String> get badges => _badges;
  String? get selectedMoodFilter => _selectedMoodFilter;
  String? get selectedLocationFilter => _selectedLocationFilter;
  Set<String> get bookmarks => _bookmarks;
  bool isBookmarked(String id) => _bookmarks.contains(id);

  List<Confession> get confessions {
    var filtered = List<Confession>.from(_confessions);

    if (_selectedMoodFilter != null) {
      filtered =
          filtered.where((c) => c.mood == _selectedMoodFilter).toList();
    }

    if (_selectedLocationFilter != null) {
      filtered = filtered
          .where((c) => c.locationTag == _selectedLocationFilter)
          .toList();
    }

    return filtered;
  }

  List<Confession> get allConfessions => _confessions;

  Confession? get confessionOfDay {
    try {
      return _confessions.firstWhere((c) => c.isConfessionOfDay);
    } catch (_) {
      return _confessions.isNotEmpty ? _confessions.first : null;
    }
  }

  List<Confession> get trendingConfessions {
    final sorted = List<Confession>.from(_confessions)
      ..sort((a, b) => b.totalReactions.compareTo(a.totalReactions));
    return sorted.take(10).toList();
  }

  int get activeNow {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _confessions.where((c) => c.createdAt.isAfter(cutoff)).length;
  }

  int get todayCount {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _confessions.where((c) => c.createdAt.isAfter(cutoff)).length;
  }

  bool isExpanded(String confessionId) =>
      _expandedConfessions.contains(confessionId);

  Set<String> getUserReactions(String confessionId) =>
      _userReactions[confessionId] ?? {};

  // Actions
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void regenerateUsername() {
    _currentUsername = UsernameGenerator.generate();
    notifyListeners();
  }

  void setMoodFilter(String? mood) {
    _selectedMoodFilter = mood == _selectedMoodFilter ? null : mood;
    notifyListeners();
  }

  void setLocationFilter(String? location) {
    _selectedLocationFilter =
        location == _selectedLocationFilter ? null : location;
    notifyListeners();
  }

  void toggleExpand(String confessionId) {
    if (_expandedConfessions.contains(confessionId)) {
      _expandedConfessions.remove(confessionId);
    } else {
      _expandedConfessions.add(confessionId);
    }
    notifyListeners();
  }

  void addReaction(String confessionId, String reaction) {
    final reactions = _userReactions[confessionId] ?? {};

    if (reactions.contains(reaction)) {
      // Deselect current reaction
      reactions.remove(reaction);
      final idx = _confessions.indexWhere((c) => c.id == confessionId);
      if (idx != -1) {
        final confession = _confessions[idx];
        final updatedReactions = Map<String, int>.from(confession.reactions);
        updatedReactions[reaction] = (updatedReactions[reaction] ?? 1) - 1;
        _confessions[idx] = confession.copyWith(reactions: updatedReactions);
      }
    } else {
      // Remove any existing reaction first
      if (reactions.isNotEmpty) {
        final previous = reactions.first;
        reactions.remove(previous);
        final idx = _confessions.indexWhere((c) => c.id == confessionId);
        if (idx != -1) {
          final confession = _confessions[idx];
          final updatedReactions = Map<String, int>.from(confession.reactions);
          updatedReactions[previous] = (updatedReactions[previous] ?? 1) - 1;
          _confessions[idx] = confession.copyWith(reactions: updatedReactions);
        }
      }
      // Add new reaction
      reactions.add(reaction);
      final idx = _confessions.indexWhere((c) => c.id == confessionId);
      if (idx != -1) {
        final confession = _confessions[idx];
        final updatedReactions = Map<String, int>.from(confession.reactions);
        updatedReactions[reaction] = (updatedReactions[reaction] ?? 0) + 1;
        _confessions[idx] = confession.copyWith(reactions: updatedReactions);
      }
      _karma += 1;
    }

    _userReactions[confessionId] = reactions;
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void toggleBookmark(String confessionId) {
    if (_bookmarks.contains(confessionId)) {
      _bookmarks.remove(confessionId);
    } else {
      _bookmarks.add(confessionId);
      HapticFeedback.selectionClick();
    }
    notifyListeners();
  }

  void addConfession({
    required String content,
    required String mood,
    String? locationTag,
    bool isDisappearing = false,
    bool isVoice = false,
  }) {
    final confession = Confession(
      anonymousName: _currentUsername,
      content: content,
      mood: mood,
      locationTag: locationTag,
      isDisappearing: isDisappearing,
      isVoice: isVoice,
    );

    _confessions.insert(0, confession);
    _selectedMoodFilter = null; // clear filter so new post is always visible
    _selectedLocationFilter = null;
    _streakDays += 1;
    _karma += 10;
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void addQuestion(String question, String? category) {
    _questions.insert(
      0,
      AskQuestion(
        anonymousName: _currentUsername,
        question: question,
        category: category,
      ),
    );
    _karma += 5;
    notifyListeners();
  }

  List<Comment> getComments(String confessionId) {
    return MockData.getComments(confessionId);
  }
}
