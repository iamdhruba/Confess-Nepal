import '../../../core/network/api_client.dart';

class AdminRepository {
  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> getAllConfessions({
    int page = 1,
    String? search,
    String? location,
    bool? isHidden,
  }) async {
    final query = {
      'page': page.toString(),
      if (search != null) 'search': search,
      if (location != null) 'location': location,
      if (isHidden != null) 'isHidden': isHidden.toString(),
    };
    return await _client.get('/admin/confessions', query: query);
  }

  Future<void> toggleHide(String id) async {
    await _client.patch('/admin/confessions/$id/hide');
  }

  Future<void> togglePin(String id) async {
    await _client.patch('/admin/confessions/$id/pin');
  }

  Future<Map<String, dynamic>> getAllQuestions({
    int page = 1,
    bool? isHidden,
  }) async {
    final query = {
      'page': page.toString(),
      if (isHidden != null) 'isHidden': isHidden.toString(),
    };
    return await _client.get('/admin/questions', query: query);
  }

  Future<void> toggleHideQuestion(String id) async {
    await _client.patch('/admin/questions/$id/hide');
  }

  Future<Map<String, dynamic>> getStats() async {
    return await _client.get('/admin/stats');
  }
}
