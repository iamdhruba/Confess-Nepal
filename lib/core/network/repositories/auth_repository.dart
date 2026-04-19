import '../api_client.dart';

class AuthRepository {
  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> deviceRegister(String deviceId) async {
    final data = await _client.post('/auth/device-register', body: {'deviceId': deviceId});
    await _client.saveToken(data['token']);
    return data['user'];
  }

  Future<Map<String, dynamic>> signup({
    required String deviceId,
    required String email,
    required String password,
    String? username,
  }) async {
    final data = await _client.post('/auth/signup', body: {
      'deviceId': deviceId,
      'email': email,
      'password': password,
      'username': username,
    }..removeWhere((key, value) => value == null));
    await _client.saveToken(data['token']);
    return data['user'];
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    await _client.saveToken(data['token']);
    return data['user'];
  }

  Future<String?> forgotPassword(String email) async {
    final data = await _client.post('/auth/forgot-password', body: {'email': email});
    return data['otp']; // only in dev
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    await _client.post('/auth/verify-otp', body: {'email': email, 'otp': otp});
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final data = await _client.post('/auth/reset-password', body: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
    await _client.saveToken(data['token']);
    return data['user'];
  }

  Future<Map<String, dynamic>> updateProfile({String? username, String? bio}) async {
    final data = await _client.patch('/auth/update-profile', body: {
      'username': username,
      'bio': bio,
    }..removeWhere((key, value) => value == null));
    return data['user'];
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.patch('/auth/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<Map<String, dynamic>> getMe() async {
    final data = await _client.get('/auth/me');
    return data['user'];
  }

  Future<String> regenerateUsername() async {
    final data = await _client.patch('/auth/regenerate-username');
    return data['username'];
  }
}
