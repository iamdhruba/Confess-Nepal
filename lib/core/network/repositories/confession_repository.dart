import '../api_client.dart';

class ConfessionRepository {
  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> getStats() async {
    return await _client.get('/confessions/stats');
  }

  Future<Map<String, dynamic>> getFeed({
    int page = 1,
    int limit = 20,
    String? mood,
    String? location,
  }) async {
    final query = <String, String>{'page': '$page', 'limit': '$limit'};
    if (mood != null) query['mood'] = mood;
    if (location != null) query['location'] = location;

    return await _client.get('/confessions', query: query);
  }

  Future<Map<String, dynamic>> getTrending({String? location}) async {
    final query = <String, String>{};
    if (location != null) query['location'] = location;
    return await _client.get('/confessions/trending', query: query);
  }

  Future<Map<String, dynamic>?> getConfessionOfDay() async {
    final data = await _client.get('/confessions/cotd');
    return data['confession'];
  }

  Future<Map<String, dynamic>> getOne(String id) async {
    final data = await _client.get('/confessions/$id');
    return data['confession'];
  }

  Future<Map<String, dynamic>> create({
    required String content,
    required String mood,
    String? locationTag,
    bool isDisappearing = false,
  }) async {
    final data = await _client.post('/confessions', body: {
      'content': content,
      'mood': mood,
      if (locationTag != null) 'locationTag': locationTag,
      'isDisappearing': isDisappearing,
    });
    return data['confession'];
  }

  Future<void> delete(String id) async {
    await _client.delete('/confessions/$id');
  }

  Future<Map<String, dynamic>> react(String id, String reactionType) async {
    return await _client.post('/confessions/$id/react', body: {
      'reactionType': reactionType,
    });
  }

  Future<Map<String, dynamic>> repost(String id) async {
    return await _client.post('/confessions/$id/repost');
  }

  Future<Map<String, dynamic>> toggleSave(String id) async {
    return await _client.post('/confessions/$id/save');
  }

  Future<Map<String, dynamic>> getUserConfessions(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _client.get(
      '/confessions/user/$userId',
      query: {'page': '$page', 'limit': '$limit'},
    );
  }

  Future<Map<String, dynamic>> searchConfessions(String query, {int page = 1, int limit = 20}) async {
    return await _client.get('/confessions/search', query: {
      'q': query,
      'page': '$page',
      'limit': '$limit',
    });
  }

  Future<List<String>> getLocations() async {
    final data = await _client.get('/confessions/locations');
    return List<String>.from(data['locations'] ?? []);
  }
  Future<List<String>> getMoods() async {
    final data = await _client.get('/confessions/moods');
    return List<String>.from(data['moods'] ?? []);
  }
  Future<Map<String, dynamic>> getSaved({int page = 1, int limit = 20}) async {
    return await _client.get('/confessions/saved', query: {'page': '$page', 'limit': '$limit'});
  }

  Future<Map<String, dynamic>> getReposted({int page = 1, int limit = 20}) async {
    return await _client.get('/confessions/reposted', query: {'page': '$page', 'limit': '$limit'});
  }
}
