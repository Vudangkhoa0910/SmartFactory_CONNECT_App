import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/idea_box_model.dart';
import 'api_service.dart';

class IdeaService {
  
  Future<List<IdeaBoxItem>> getIdeas({
    required IdeaBoxType type,
    int page = 1,
    int limit = 20,
    String? status,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'ideabox_type': type == IdeaBoxType.white ? 'white' : 'pink',
      };

      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/api/ideas?$queryString';

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((json) => IdeaBoxItem.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Failed to load ideas');
        }
      } else {
        throw Exception('Failed to load ideas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting ideas: $e');
      rethrow;
    }
  }

  Future<IdeaBoxItem> createIdea({
    required IdeaBoxType type,
    required IssueType issueType,
    required String title,
    required String content,
    List<File>? attachments,
    String? expectedBenefit,
  }) async {
    try {
      String category;
      switch (issueType) {
        case IssueType.quality: category = 'quality_improvement'; break;
        case IssueType.safety: category = 'safety_enhancement'; break;
        case IssueType.performance: category = 'productivity'; break;
        case IssueType.energySaving: category = 'cost_reduction'; break;
        case IssueType.process: category = 'process_improvement'; break;
        case IssueType.workEnvironment: category = 'workplace'; break;
        case IssueType.welfare: category = 'workplace'; break;
        case IssueType.pressure: category = 'workplace'; break;
        case IssueType.psychologicalSafety: category = 'workplace'; break;
        case IssueType.fairness: category = 'workplace'; break;
        default: category = 'other';
      }

      final Map<String, String> fields = {
        'ideabox_type': type == IdeaBoxType.white ? 'white' : 'pink',
        'category': category,
        'title': title,
        'description': content,
      };

      if (expectedBenefit != null) {
        fields['expected_benefit'] = expectedBenefit;
      }

      List<http.MultipartFile> files = [];
      if (attachments != null) {
        for (var file in attachments) {
          files.add(await http.MultipartFile.fromPath(
            'attachments',
            file.path,
          ));
        }
      }

      final streamedResponse = await ApiService.postMultipart(
        '/api/ideas',
        fields,
        files,
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return IdeaBoxItem.fromJson(body['data']);
        } else {
          throw Exception(body['message'] ?? 'Failed to create idea');
        }
      } else {
        throw Exception('Failed to create idea: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating idea: $e');
      rethrow;
    }
  }

  Future<IdeaBoxItem> getIdeaDetail(String id) async {
    try {
      final response = await ApiService.get('/api/ideas/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return IdeaBoxItem.fromJson(body['data']);
        } else {
          throw Exception(body['message'] ?? 'Failed to load idea detail');
        }
      } else {
        throw Exception('Failed to load idea detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting idea detail: $e');
      rethrow;
    }
  }
}
