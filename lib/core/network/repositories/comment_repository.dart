import '../api_client.dart';

class CommentRepository {
  final _client = ApiClient.instance;

  Future<List<dynamic>> getComments(String confessionId) async {
    final data = await _client.get('/confessions/$confessionId/comments');
    return data['comments'];
  }

  Future<Map<String, dynamic>> create({
    required String confessionId,
    required String content,
    String? parentId,
  }) async {
    final data = await _client.post(
      '/confessions/$confessionId/comments',
      body: {
        'content': content,
        if (parentId != null) 'parentId': parentId,
      },
    );
    return data['comment'];
  }

  Future<int> upvote(String commentId) async {
    final data = await _client.post('/comments/$commentId/upvote');
    return data['upvotes'];
  }

  Future<void> delete(String commentId) async {
    await _client.delete('/comments/$commentId');
  }
}
