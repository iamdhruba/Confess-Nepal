import '../api_client.dart';

class NotificationRepository {
  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> getAll() async {
    return await _client.get('/notifications');
  }

  Future<void> markAllAsRead() async {
    await _client.patch('/notifications/mark-read');
  }

  Future<void> markAsRead(String id) async {
    await _client.patch('/notifications/$id/mark-read');
  }
}
