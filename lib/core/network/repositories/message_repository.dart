import '../api_client.dart';

class MessageRepository {
  final _client = ApiClient.instance;

  Future<void> sendDM({
    required String toUserId,
    required String content,
    String? contextConfessionId,
  }) async {
    await _client.post('/messages', body: {
      'toUserId': toUserId,
      'content': content,
      'contextConfessionId': contextConfessionId,
    }..removeWhere((key, value) => value == null));
  }

  Future<List<dynamic>> getInbox() async {
    final data = await _client.get('/messages/inbox');
    return data['messages'];
  }

  Future<int> getUnreadCount() async {
    final data = await _client.get('/messages/unread-count');
    return data['count'] as int;
  }

  Future<void> markRead(String messageId) async {
    await _client.patch('/messages/$messageId/read');
  }
}
