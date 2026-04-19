import 'package:flutter/material.dart';
import '../models/ask_question.dart';
import '../models/ask_answer.dart';
import '../../../core/network/repositories/question_repository.dart';

class AskNepalProvider extends ChangeNotifier {
  final _questionRepo = QuestionRepository();

  List<AskQuestion> _questions = [];
  bool _isLoading = false;
  String? _error;

  List<AskQuestion> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadQuestions({String? category}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _questionRepo.getAll(category: category);
      _questions = (data['questions'] as List)
          .map((q) => AskQuestion.fromMap(q as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns karma delta (+5)
  Future<int> addQuestion(String question, String? category) async {
    try {
      final data = await _questionRepo.create(
        question: question,
        category: category,
      );
      _questions.insert(0, AskQuestion.fromMap(data));
      notifyListeners();
      return 5;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  Future<AskQuestion> getQuestionById(String id) async {
    final data = await _questionRepo.getOne(id);
    return AskQuestion.fromMap(data);
  }

  Future<void> upvoteQuestion(String id) async {
    try {
      final res = await _questionRepo.upvote(id);
      final int upvotes = res['upvotes'];
      final bool hasUpvoted = res['hasUpvoted'];
      
      final idx = _questions.indexWhere((q) => q.id == id);
      if (idx != -1) {
        _questions[idx] = _questions[idx].copyWith(
          upvotes: upvotes,
          hasUpvoted: hasUpvoted,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // --- Answers ---
  List<AskAnswer> _answers = [];
  List<AskAnswer> get answers => _answers;

  Future<void> loadAnswers(String questionId) async {
    try {
      _isLoading = true;
      notifyListeners();
      final data = await _questionRepo.getAnswers(questionId);
      _answers = data.map((a) => AskAnswer.fromMap(a as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAnswer(String questionId, String content) async {
    try {
      final data = await _questionRepo.postAnswer(questionId, content);
      final newAnswer = AskAnswer.fromMap(data);
      _answers.add(newAnswer);

      // Optimistic/Immediate update of answer count in the questions list
      final idx = _questions.indexWhere((q) => q.id == questionId);
      if (idx != -1) {
        _questions[idx] = _questions[idx].copyWith(
          answerCount: _questions[idx].answerCount + 1,
        );
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteQuestion(String id) async {
    try {
      await _questionRepo.delete(id);
      _questions.removeWhere((q) => q.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
