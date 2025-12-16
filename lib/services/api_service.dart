import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class ApiService {
  static const String _keyServerIp = 'server_ip';
  static const String _keyServerPort = 'server_port';

  static const String defaultIp = '192.168.1.8';
  static const String defaultPort = '3001';

  // Available IP range
  static const List<String> availableIps = [
    '192.168.79.19',
    '172.16.0.100',
    '172.16.0.101',
    '172.16.0.102',
    '172.16.0.103',
    '172.16.0.104',
    '172.16.0.105',
    '172.16.0.106',
    '172.16.0.107',
    '172.16.0.108',
    '172.16.0.109',
    '172.16.0.110',
  ];

  static String? _authToken;

  // Set auth token
  static void setAuthToken(String? token) {
    _authToken = token;
  }

  // Get saved IP
  static Future<String> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyServerIp) ?? defaultIp;
  }

  // Get saved Port
  static Future<String> getServerPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyServerPort) ?? defaultPort;
  }

  // Get full base URL
  static Future<String> getBaseUrl() async {
    final ip = await getServerIp();
    final port = await getServerPort();
    return 'http://$ip:$port';
  }

  // Save IP
  static Future<void> setServerIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerIp, ip);
  }

  // Save Port
  static Future<void> setServerPort(String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerPort, port);
  }

  // Helper to get headers
  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Ping server health endpoint
  static Future<Map<String, dynamic>> pingHealth() async {
    try {
      final baseUrl = await getBaseUrl();
      // Try a simple GET to root or health if exists, otherwise just check connectivity
      // Since we don't know if /health exists, we can try /api/auth/verify or just catch connection error
      // For now, let's assume we just want to check if we can reach the server.
      // We'll try to fetch the base URL.
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5));

      // Any response means server is reachable
      return {
        'success': true,
        'message': 'Kết nối thành công!',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối: $e',
        'error': e.toString(),
      };
    }
  }

  // Generic GET request
  static Future<http.Response> get(String endpoint) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _getHeaders());
  }

  // Generic POST request
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, headers: _getHeaders(), body: jsonEncode(body));
  }

  // Generic PUT request
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(url, headers: _getHeaders(), body: jsonEncode(body));
  }

  // Generic DELETE request
  static Future<http.Response> delete(String endpoint) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: _getHeaders());
  }

  // Generic Multipart POST request with timeout
  static Future<http.StreamedResponse> postMultipart(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl$endpoint');

    var request = http.MultipartRequest('POST', url);

    // Add headers (excluding Content-Type as MultipartRequest sets it)
    final headers = _getHeaders();
    headers.remove('Content-Type'); // Let the request handle the boundary
    request.headers.addAll(headers);

    // Add fields
    request.fields.addAll(fields);

    // Add files
    request.files.addAll(files);

    // Send with timeout (60 seconds for file uploads)
    try {
      final client = http.Client();
      try {
        final streamedResponse = await client
            .send(request)
            .timeout(
              const Duration(seconds: 60),
              onTimeout: () {
                client.close();
                throw TimeoutException('Upload timed out after 60 seconds');
              },
            );
        return streamedResponse;
      } finally {
        // Don't close client here - let the caller consume the response stream first
      }
    } catch (e) {
      if (e is TimeoutException) {
        rethrow;
      }
      throw Exception('Failed to upload: $e');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
