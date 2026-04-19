import '../api_client.dart';

class UserRepository {
  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> getMyProfile() async {
    final data = await _client.get('/users/profile');
    return data['user'];
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    final data = await _client.get('/users/$userId/profile');
    return data['user'];
  }

  Future<void> report({
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    await _client.post('/reports', body: {
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
    });
  }
}
