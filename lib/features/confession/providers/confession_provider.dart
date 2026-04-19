import 'package:flutter/material.dart';
import '../models/confession.dart';
import '../models/comment.dart';
import '../../../core/network/repositories/confession_repository.dart';
import '../../../core/network/repositories/comment_repository.dart';
import '../../../core/network/repositories/user_repository.dart';
import '../../profile/providers/profile_provider.dart';

class ConfessionProvider extends ChangeNotifier {
  final _confessionRepo = ConfessionRepository();
  final _commentRepo = CommentRepository();
  final _userRepo = UserRepository();

  // Expose repo so other screens can call getUserConfessions directly
  ConfessionRepository get confessionRepo => _confessionRepo;

  List<Confession> _confessions = [];
  List<Confession> _trending = [];
  List<Confession> _saved = [];
  List<Confession> _reposted = [];
  List<String> _dynamicLocations = [];
  List<String> _dynamicMoods = [];
  Confession? _confessionOfDay;
  String? _selectedMoodFilter;
  String? _selectedLocationFilter;
  int _todayCount = 0;
  int _activeCount = 0;
  int _trendingCount = 0;

  bool _isLoading = false;
  bool _isTrendingLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  List<Confession> get confessions => _confessions;
  List<Confession> get trending => _trending;
  List<Confession> get saved => _saved;
  List<Confession> get reposted => _reposted;
  List<String> get dynamicLocations => _dynamicLocations;
  List<String> get dynamicMoods => _dynamicMoods;
  Confession? get confessionOfDay => _confessionOfDay;
  String? get selectedMoodFilter => _selectedMoodFilter;
  String? get selectedLocationFilter => _selectedLocationFilter;
  int get todayCount => _todayCount;
  int get activeCount => _activeCount;
  int get trendingCount => _trendingCount;
  bool get isLoading => _isLoading;
  bool get isTrendingLoading => _isTrendingLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadStats() async {
    try {
      final data = await _confessionRepo.getStats();
      _todayCount = (data['todayCount'] as num).toInt();
      _activeCount = (data['activeCount'] as num).toInt();
      _trendingCount = (data['trendingCount'] as num).toInt();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadLocations() async {
    try {
      final locs = await _confessionRepo.getLocations();
      _dynamicLocations = locs;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadMoods() async {
    try {
      final mds = await _confessionRepo.getMoods();
      _dynamicMoods = mds;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadFeed({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _confessions = [];
    }
    if (!_hasMore) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _confessionRepo.getFeed(
        page: _currentPage,
        mood: _selectedMoodFilter,
        location: _selectedLocationFilter,
      );

      final fetched = (data['confessions'] as List)
          .map((c) => Confession.fromMap(c as Map<String, dynamic>))
          .toList();

      _confessions = refresh ? fetched : [..._confessions, ...fetched];
      _hasMore = _currentPage < (data['totalPages'] as int);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTrending() async {
    try {
      _isTrendingLoading = true;
      notifyListeners();

      final data = await _confessionRepo.getTrending(
        location: _selectedLocationFilter,
      );
      _trending = (data['confessions'] as List)
          .map((c) => Confession.fromMap(c as Map<String, dynamic>))
          .toList();
          
      // Ensure it's sorted by reactions for proper ranking
      _trending.sort((a, b) => b.totalReactions.compareTo(a.totalReactions));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isTrendingLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSaved() async {
    try {
      _isLoading = true;
      notifyListeners();
      final data = await _confessionRepo.getSaved();
      _saved = (data['confessions'] as List)
          .map((c) => Confession.fromMap(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReposted() async {
    try {
      _isLoading = true;
      notifyListeners();
      final data = await _confessionRepo.getReposted();
      _reposted = (data['confessions'] as List)
          .map((c) => Confession.fromMap(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConfessionOfDay() async {
    try {
      final data = await _confessionRepo.getConfessionOfDay();
      if (data != null) {
        _confessionOfDay = Confession.fromMap(data);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<List<Comment>> getComments(String confessionId) async {
    final data = await _commentRepo.getComments(confessionId);
    return data.map((c) => Comment.fromMap(c as Map<String, dynamic>)).toList();
  }

  void setMoodFilter(String? mood) {
    _selectedMoodFilter = mood == _selectedMoodFilter ? null : mood;
    loadFeed(refresh: true);
  }

  void setLocationFilter(String? location) {
    _selectedLocationFilter = location == _selectedLocationFilter ? null : location;
    loadFeed(refresh: true);
    loadTrending();
  }

  /// Returns karma delta for ProfileProvider to consume
  Future<int> addReaction(String confessionId, String reactionType) async {
    try {
      // Find the confession in any list it might be in
      Confession? target;
      try {
        target = _confessions.firstWhere((c) => c.id == confessionId);
      } catch (_) {
        try {
          target = _trending.firstWhere((c) => c.id == confessionId);
        } catch (_) {
          if (_confessionOfDay?.id == confessionId) target = _confessionOfDay;
        }
      }

      if (target == null) return 0;

      final currentReactions = target.userReactions;
      
      // If user has other reactions, remove them first (Mutual Exclusive)
      if (currentReactions.isNotEmpty && !currentReactions.contains(reactionType)) {
        for (final r in currentReactions) {
          await _confessionRepo.react(confessionId, r);
        }
      }

      // Toggle/Add the requested reaction
      final data = await _confessionRepo.react(confessionId, reactionType);
      
      final updatedReactions = Map<String, int>.from(
        (data['reactions'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      );
      final userReactions = List<String>.from(data['userReactions']);

      // Update in all lists
      _updateConfessionInList(_confessions, confessionId, updatedReactions, userReactions);
      _updateConfessionInList(_trending, confessionId, updatedReactions, userReactions);
      if (_confessionOfDay?.id == confessionId) {
        _confessionOfDay = _confessionOfDay!.copyWith(
          reactions: updatedReactions,
          userReactions: userReactions,
        );
      }

      notifyListeners();

      // Return karma: +1 if selected, 0 if deselected
      return userReactions.contains(reactionType) ? 1 : 0;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  Future<int> addConfession({
    required String content,
    required String mood,
    String? locationTag,
    bool isDisappearing = false,
    required ProfileProvider profileProvider,
  }) async {
    try {
      await profileProvider.ensureAuth();
      final data = await _confessionRepo.create(
        content: content,
        mood: mood,
        locationTag: locationTag,
        isDisappearing: isDisappearing,
      );
      final confession = Confession.fromMap(data);
      
      // Check if it matches current filters to decide if we prepend
      bool matchesMood = _selectedMoodFilter == null || _selectedMoodFilter == mood;
      bool matchesLocation = _selectedLocationFilter == null || _selectedLocationFilter == locationTag;

      if (matchesMood && matchesLocation) {
        _confessions.insert(0, confession);
      }
      
      // Optimistically add location if it's new
      if (locationTag != null && !_dynamicLocations.contains(locationTag)) {
        _dynamicLocations.add(locationTag);
      }
      
      // Optimistically add mood if it's new
      if (!_dynamicMoods.contains(mood)) {
        _dynamicMoods.add(mood);
      }
      
      // Local real-time update of stats
      _todayCount += 1;
      _activeCount += 1;
      
      notifyListeners();
      
      // Auto-refresh feed to sync with backend after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        loadFeed(refresh: true);
        loadLocations();
        loadMoods();
      });
      
      return 10;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  Future<Confession> getConfessionById(String id) async {
    final data = await _confessionRepo.getOne(id);
    return Confession.fromMap(data);
  }

  Future<bool> repost(String confessionId) async {
    try {
      final data = await _confessionRepo.repost(confessionId);
      final newCount = (data['repostCount'] as num?)?.toInt() ?? 0;
      final userReposted = data['userReposted'] as bool? ?? false;
      _updateInAllLists(confessionId, repostCount: newCount, userReposted: userReposted);
      notifyListeners();
      return userReposted;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleSave(String confessionId) async {
    try {
      final data = await _confessionRepo.toggleSave(confessionId);
      final newCount = (data['saveCount'] as num?)?.toInt() ?? 0;
      final saved = (data['saved'] as bool?) ?? false;
      _updateInAllLists(confessionId, saveCount: newCount, userSaved: saved);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _updateInAllLists(String id, {int? repostCount, int? saveCount, bool? userSaved, bool? userReposted}) {
    for (final list in [_confessions, _trending, _saved, _reposted]) {
      final idx = list.indexWhere((c) => c.id == id);
      if (idx != -1) list[idx] = list[idx].copyWith(repostCount: repostCount, saveCount: saveCount, userSaved: userSaved, userReposted: userReposted);
    }
    if (_confessionOfDay?.id == id) {
      _confessionOfDay = _confessionOfDay!.copyWith(repostCount: repostCount, saveCount: saveCount, userSaved: userSaved, userReposted: userReposted);
    }
  }

  Future<void> deleteConfession(String id) async {
    try {
      await _confessionRepo.delete(id);
      _confessions.removeWhere((c) => c.id == id);
      _trending.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addComment({
    required String confessionId,
    required String content,
    String? parentId,
  }) async {
    await _commentRepo.create(
      confessionId: confessionId,
      content: content,
      parentId: parentId,
    );
    // Increment local comment count
    _updateCommentCount(confessionId, 1);
    notifyListeners();
  }

  Future<void> report({
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    await _userRepo.report(
      targetType: targetType,
      targetId: targetId,
      reason: reason,
    );
  }

  void _updateConfessionInList(
    List<Confession> list,
    String id,
    Map<String, int> reactions,
    List<String> userReactions,
  ) {
    final idx = list.indexWhere((c) => c.id == id);
    if (idx != -1) {
      list[idx] = list[idx].copyWith(
        reactions: reactions,
        userReactions: userReactions,
      );
    }
  }

  void _updateCommentCount(String confessionId, int delta) {
    final idx = _confessions.indexWhere((c) => c.id == confessionId);
    if (idx != -1) {
      _confessions[idx] = _confessions[idx].copyWith(
        commentCount: _confessions[idx].commentCount + delta,
      );
    }
  }
}
