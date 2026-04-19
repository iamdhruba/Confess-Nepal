import 'package:flutter/material.dart';
import '../../../core/network/repositories/admin_repository.dart';
import '../../confession/models/confession.dart';
import '../../ask_nepal/models/ask_question.dart';

class AdminProvider extends ChangeNotifier {
  final _adminRepo = AdminRepository();

  Map<String, dynamic> _stats = {};
  List<Confession> _confessions = [];
  List<AskQuestion> _questions = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get stats => _stats;
  List<Confession> get confessions => _confessions;
  List<AskQuestion> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStats() async {
    try {
      _isLoading = true;
      notifyListeners();
      _stats = await _adminRepo.getStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConfessions({bool refresh = false}) async {
    try {
      _isLoading = true;
      notifyListeners();
      final data = await _adminRepo.getAllConfessions();
      _confessions = (data['confessions'] as List)
          .map((c) => Confession.fromMap(c))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleHide(String id) async {
    try {
      await _adminRepo.toggleHide(id);
      final idx = _confessions.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _confessions[idx] = _confessions[idx].copyWith(isHidden: !_confessions[idx].isHidden);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> togglePin(String id) async {
    try {
      await _adminRepo.togglePin(id);
      // Unpin others and pin this one
      for (int i = 0; i < _confessions.length; i++) {
        if (_confessions[i].id == id) {
          _confessions[i] = _confessions[i].copyWith(isConfessionOfDay: true);
        } else {
          _confessions[i] = _confessions[i].copyWith(isConfessionOfDay: false);
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // --- Questions ---

  Future<void> loadQuestions({bool refresh = false}) async {
    try {
      _isLoading = true;
      notifyListeners();
      final data = await _adminRepo.getAllQuestions();
      _questions = (data['questions'] as List)
          .map((q) => AskQuestion.fromMap(q))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleHideQuestion(String id) async {
    try {
      await _adminRepo.toggleHideQuestion(id);
      final idx = _questions.indexWhere((q) => q.id == id);
      if (idx != -1) {
        _questions[idx] = _questions[idx].copyWith(isHidden: !_questions[idx].isHidden);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
