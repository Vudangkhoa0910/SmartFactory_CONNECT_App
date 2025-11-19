import 'dart:convert';
import 'api_service.dart';
import 'api_constants.dart';

class NewsService {
  // Get all news
  static Future<List<dynamic>> getNews({int page = 1, int limit = 10}) async {
    try {
      final response = await ApiService.get(
        '${ApiConstants.news}?page=$page&limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }

  // Get news by ID
  static Future<Map<String, dynamic>?> getNewsById(String id) async {
    try {
      final response = await ApiService.get('${ApiConstants.news}/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching news detail: $e');
      return null;
    }
  }
}
