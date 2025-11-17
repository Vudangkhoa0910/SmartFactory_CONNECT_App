import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String _keyServerIp = 'server_ip';
  static const String _keyServerPort = 'server_port';

  // Default values
  static const String defaultIp = '192.168.1.10';
  static const String defaultPort = '3001';

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

  // Ping server health endpoint
  static Future<Map<String, dynamic>> pingHealth() async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/health');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Kết nối thành công!',
          'statusCode': response.statusCode,
          'data': response.body.isNotEmpty ? jsonDecode(response.body) : null,
        };
      } else {
        return {
          'success': false,
          'message': 'Server phản hồi lỗi: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
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
    return await http.get(url);
  }

  // Generic POST request
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }
}
