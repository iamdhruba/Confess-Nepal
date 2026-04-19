import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/repositories/auth_repository.dart';
import '../../../core/utils/username_generator.dart';

class ProfileProvider extends ChangeNotifier {
  final _authRepo = AuthRepository();

  String _userId = '';
  String _currentUsername = '';
  String _email = '';
  String _bio = '';
  int _streakDays = 0;
  int _karma = 0;
  int _totalConfessions = 0;
  int _totalComments = 0;
  List<String> _badges = [];
  bool _hasEmail = false;
  ThemeMode _themeMode = ThemeMode.dark;

  bool _isLoading = false;
  bool _isAuthLoading = false;
  String? _error;
  String _role = 'user';

  // Getters
  String get userId => _userId;
  String get currentUsername => _currentUsername;
  String get email => _email;
  String get bio => _bio;
  int get streakDays => _streakDays;
  int get karma => _karma;
  int get totalConfessions => _totalConfessions;
  int get totalComments => _totalComments;
  List<String> get badges => _badges;
  bool get hasEmail => _hasEmail;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isAuthLoading => _isAuthLoading;
  String? get error => _error;
  String get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isAuthenticated => ApiClient.instance.isAuthenticated;

  Future<void> init() async {
    // ApiClient.init() is already called in main() before runApp
    if (ApiClient.instance.isAuthenticated) {
      await _loadProfile();
    } else {
      await _deviceRegister();
    }
  }

  Future<void> ensureAuth() async {
    if (!ApiClient.instance.isAuthenticated) {
      await _deviceRegister();
    }
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  Future<void> _deviceRegister() async {
    try {
      _isLoading = true;
      notifyListeners();
      final deviceId = await _getDeviceId();
      final user = await _authRepo.deviceRegister(deviceId);
      _applyUser(user);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    try {
      _isLoading = true;
      notifyListeners();
      final user = await _authRepo.getMe();
      _applyUser(user);
    } catch (e) {
      await ApiClient.instance.clearToken();
      await _deviceRegister();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Signup with email + password
  Future<String?> signup({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      _isAuthLoading = true;
      _error = null;
      notifyListeners();
      final deviceId = await _getDeviceId();
      final user = await _authRepo.signup(
        deviceId: deviceId,
        email: email,
        password: password,
        username: username,
      );
      _applyUser(user);
      return null; // no error
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  // Login with email + password
  Future<String?> login({required String email, required String password}) async {
    try {
      _isAuthLoading = true;
      _error = null;
      notifyListeners();
      final user = await _authRepo.login(email: email, password: password);
      _applyUser(user);
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  // Forgot password — returns OTP (dev only)
  Future<String?> forgotPassword(String email) async {
    try {
      _isAuthLoading = true;
      _error = null;
      notifyListeners();
      final otp = await _authRepo.forgotPassword(email);
      return otp;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<String?> verifyOtp({required String email, required String otp}) async {
    try {
      _isAuthLoading = true;
      _error = null;
      notifyListeners();
      await _authRepo.verifyOtp(email: email, otp: otp);
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<String?> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      _isAuthLoading = true;
      _error = null;
      notifyListeners();
      final user = await _authRepo.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      _applyUser(user);
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateProfile({String? username, String? bio}) async {
    try {
      _isAuthLoading = true;
      _error = null;
      notifyListeners();
      final user = await _authRepo.updateProfile(username: username, bio: bio);
      _applyUser(user);
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isAuthLoading = true;
      _error = null;
      notifyListeners();
      await _authRepo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> regenerateUsername() async {
    try {
      final username = await _authRepo.regenerateUsername();
      _currentUsername = username;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiClient.instance.clearToken();
    // Re-register as anonymous device user
    await _deviceRegister();
  }

  void _applyUser(Map<String, dynamic> user) {
    _userId = user['_id'] ?? '';
    _currentUsername = user['username'] ?? UsernameGenerator.generate();
    _email = user['email'] ?? '';
    _bio = user['bio'] ?? '';
    _hasEmail = (_email).isNotEmpty;
    _streakDays = (user['streakDays'] ?? 0) as int;
    _karma = (user['karma'] ?? 0) as int;
    _totalConfessions = (user['totalConfessions'] ?? 0) as int;
    _totalComments = (user['totalComments'] ?? 0) as int;
    _role = user['role'] ?? 'user';
    _badges = user['badges'] != null ? List<String>.from(user['badges']) : [];
  }

  void addKarma(int delta) {
    _karma += delta;
    notifyListeners();
  }

  void incrementStreak() {
    _streakDays += 1;
    notifyListeners();
  }

  void incrementTotalConfessions() {
    _totalConfessions += 1;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
