import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class ApiService {
  // Get base URL from configuration
  static String get baseUrl => AppConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    return headers;
  }

  static Future<Map<String, String>> _getAuthHeaders(String token) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    return headers;
  }

  /// Performs a GET request.
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.get(url, headers: headers).timeout(AppConfig.connectionTimeout);
  }

  /// Performs an authenticated GET request.
  static Future<http.Response> getWithAuth(
    String endpoint,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getAuthHeaders(token);
    return http.get(url, headers: headers).timeout(AppConfig.connectionTimeout);
  }

  /// Performs a POST request.
  static Future<http.Response> post(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.post(url, headers: headers, body: jsonEncode(body));
  }

  /// Performs a POST request.
  static Future<http.Response> postWithAuth(
    String token,
    String endpoint,
    dynamic body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getAuthHeaders(token);
    return http.post(url, headers: headers, body: jsonEncode(body));
  }

  /// Performs a PUT request.
  static Future<http.Response> put(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.put(url, headers: headers, body: jsonEncode(body));
  }

  /// Performs a PATCH request.
  static Future<http.Response> patch(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.patch(url, headers: headers, body: jsonEncode(body));
  }

  /// Performs an authenticated PATCH request.
  static Future<http.Response> patchWithAuth(
    String token,
    String endpoint,
    dynamic body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getAuthHeaders(token);
    return http.patch(url, headers: headers, body: jsonEncode(body));
  }

  /// Performs a DELETE request.
  static Future<http.Response> delete(
    String endpoint, {
    dynamic body,
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.delete(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// Uploads one or more files using a multipart request.
  static Future<http.Response> uploadFile(
    String endpoint, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    headers.remove('Content-Type');

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields.addAll(fields)
      ..files.addAll(files);

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  /// Uploads one or more files using a multipart request with authentication.
  static Future<http.Response> uploadFileWithAuth(
    String token,
    String endpoint, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getAuthHeaders(token);

    headers.remove('Content-Type');

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields.addAll(fields)
      ..files.addAll(files);

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  // User-specific API methods

  /// Registers a new user
  static Future<http.Response> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    return post('/users/register', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  /// Logs in a user
  static Future<http.Response> loginUser({
    required String email,
    required String password,
  }) async {
    return post('/users/login', {'email': email, 'password': password});
  }

  /// Gets user profile (requires authentication)
  static Future<http.Response> getUserProfile(String token) async {
    return getWithAuth('/users/profile', token);
  }

  /// Updates user username (requires authentication)
  static Future<http.Response> updateUsername(
    String token,
    String newUsername,
  ) async {
    return patchWithAuth(token, '/users/username', {
      'newUsername': newUsername,
    });
  }

  /// Gets user booking history with payments (requires authentication)
  static Future<http.Response> getBookingHistory(String token) async {
    return getWithAuth('/users/booking-history', token);
  }

  /// Gets user booking history with payments by userId (no auth)
  static Future<http.Response> getBookingHistoryByUserId(
    String userId,
    String token,
  ) async {
    final endpoint =
        '/users/booking-history/by-userId?userId=' +
        Uri.encodeComponent(userId);
    return getWithAuth(endpoint, token);
  }

  /// Searches for events using the backend search endpoint
  static Future<http.Response> searchEvents(String query) async {
    final endpoint = '/events/search?query=' + Uri.encodeComponent(query);
    return get(endpoint);
  }

  /// Searches for events using the backend search endpoint (authenticated)
  static Future<http.Response> searchEventsWithAuth(
    String token,
    String query,
  ) async {
    final endpoint = '/events/search?query=' + Uri.encodeComponent(query);
    return getWithAuth(endpoint, token);
  }

  /// Searches for events by category using the backend search endpoint
  static Future<http.Response> searchEventsByCategory(
    String query,
    String category,
  ) async {
    final endpoint =
        '/events/search/category?query=' +
        Uri.encodeComponent(query) +
        '&category=' +
        Uri.encodeComponent(category);
    return get(endpoint);
  }

  /// Searches for events by category using the backend search endpoint (authenticated)
  static Future<http.Response> searchEventsByCategoryWithAuth(
    String token,
    String query,
    String category,
  ) async {
    final endpoint =
        '/events/search/category?query=' +
        Uri.encodeComponent(query) +
        '&category=' +
        Uri.encodeComponent(category);
    return getWithAuth(endpoint, token);
  }

  /// Gets upcoming events
  static Future<http.Response> getUpcomingEvents() async {
    return get('/events/upcoming');
  }

  /// Gets upcoming events (authenticated)
  static Future<http.Response> getUpcomingEventsWithAuth(String token) async {
    return getWithAuth('/events/upcoming', token);
  }

  /// Searches for upcoming events
  static Future<http.Response> searchUpcomingEvents(String query) async {
    final endpoint =
        '/events/search/upcoming?query=' + Uri.encodeComponent(query);
    return get(endpoint);
  }

  /// Searches for upcoming events (authenticated)
  static Future<http.Response> searchUpcomingEventsWithAuth(
    String token,
    String query,
  ) async {
    final endpoint =
        '/events/search/upcoming?query=' + Uri.encodeComponent(query);
    return getWithAuth(endpoint, token);
  }
}
