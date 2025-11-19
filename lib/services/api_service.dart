import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class ApiService {
  static const String _keyServerIp = 'server_ip';
  static const String _keyServerPort = 'server_port';

  // Default values
  static const String defaultIp = '192.168.79.19';
  static const String defaultPort = '3001';

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

  // Generic Multipart POST request
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

    return await request.send();
  }
}
