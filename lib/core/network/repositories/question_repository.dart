import '../api_client.dart';

class QuestionRepository {
  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> getAll({
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    final query = <String, String>{'page': '$page', 'limit': '$limit'};
    if (category != null) query['category'] = category;
    return await _client.get('/questions', query: query);
  }

  Future<Map<String, dynamic>> create({
    required String question,
    String? category,
  }) async {
    final data = await _client.post('/questions', body: {
      'question': question,
      if (category != null) 'category': category,
    });
    return data['question'];
  }

  Future<Map<String, dynamic>> getOne(String id) async {
    final data = await _client.get('/questions/$id');
    return data['question'];
  }

  Future<Map<String, dynamic>> upvote(String id) async {
    final data = await _client.post('/questions/$id/upvote');
    return data;
  }

  Future<void> delete(String id) async {
    await _client.delete('/questions/$id');
  }

  Future<List<dynamic>> getUserQuestions(String userId) async {
    final data = await _client.get('/questions/user/$userId');
    return data['questions'];
  }

  Future<List<dynamic>> getAnswers(String questionId) async {
    final data = await _client.get('/questions/$questionId/answers');
    return data['answers'];
  }

  Future<Map<String, dynamic>> postAnswer(String questionId, String content) async {
    final data = await _client.post('/questions/$questionId/answers', body: {'content': content});
    return data['answer'];
  }
}
