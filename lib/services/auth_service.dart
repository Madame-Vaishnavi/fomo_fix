import 'dart:convert';
import '../models/user.dart';
import 'api-service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static FlutterSecureStorage _secureStorage= FlutterSecureStorage();

  static String? _token;
  static User? _currentUser;

  // Get current token
  static String? get token => _token;

  // Get current user
  static User? get currentUser => _currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => _token != null;

  // Set token and user
  static Future<void> setAuth(String token, User user) async {
    _token = token;
    _currentUser = user;

  }

  // Clear auth data
  static Future<void> clearAuth() async {
    _token = null;
    _currentUser = null;

    await _secureStorage.deleteAll();
  }

  // Login user
  static Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.loginUser(
        email: email,
        password: password,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userId = data['userId'].toString();
        print('Token: $token');
        await _secureStorage.write(key: 'token', value: token);
        await _secureStorage.write(key: 'userId', value: userId);
        print('Token saved: ${await _secureStorage.read(key: 'token')}');

        // Get user profile
        final profileResponse = await ApiService.getUserProfile(token);

        if (profileResponse.statusCode == 200) {
          final userData = jsonDecode(profileResponse.body);
          final user = User.fromJson(userData);

          setAuth(token, user);
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Register user
  static Future<bool> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await ApiService.registerUser(
        username: username,
        email: email,
        password: password,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Logout user
  static void logout() {
    clearAuth();
  }
}

