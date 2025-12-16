import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';
import 'api_constants.dart';

class IncidentService {
  // Helper to get MIME type from file path
  static MediaType _getMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;

    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'webm':
        return MediaType('video', 'webm');
      case 'm4a':
        return MediaType('audio', 'm4a');
      case 'aac':
        return MediaType('audio', 'aac');
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'wav':
        return MediaType('audio', 'wav');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  static Future<Map<String, dynamic>> createIncident({
    required String title,
    required String description,
    required String location,
    required String priority,
    required String incidentType,
    List<File>? images,
    List<File>? videos,
    String? audioPath,
  }) async {
    try {
      print('📦 Creating incident request...');

      final fields = {
        'title': title,
        'description': description,
        'location': location,
        'priority': priority,
        'incident_type': incidentType,
      };

      print('📦 Fields prepared: $fields');

      List<http.MultipartFile> files = [];

      print('📦 Processing images: ${images?.length ?? 0}');
      if (images != null) {
        for (var i = 0; i < images.length; i++) {
          print('📦 Reading image $i: ${images[i].path}');
          try {
            final mimeType = _getMimeType(images[i].path);
            final multipartFile = await http.MultipartFile.fromPath(
              'files',
              images[i].path,
              contentType: mimeType,
            );
            files.add(multipartFile);
            print(
              '✅ Image $i added (${multipartFile.length} bytes, type: $mimeType)',
            );
          } catch (e) {
            print('❌ Error reading image $i: $e');
            throw Exception('Failed to read image: $e');
          }
        }
      }

      print('📦 Processing videos: ${videos?.length ?? 0}');
      if (videos != null) {
        for (var i = 0; i < videos.length; i++) {
          print('📦 Reading video $i: ${videos[i].path}');
          final mimeType = _getMimeType(videos[i].path);
          files.add(
            await http.MultipartFile.fromPath(
              'files',
              videos[i].path,
              contentType: mimeType,
            ),
          );
          print('✅ Video $i added (type: $mimeType)');
        }
      }

      if (audioPath != null) {
        print('📦 Reading audio: $audioPath');
        final mimeType = _getMimeType(audioPath);
        files.add(
          await http.MultipartFile.fromPath(
            'files',
            audioPath,
            contentType: mimeType,
          ),
        );
        print('✅ Audio added (type: $mimeType)');
      }

      print('📤 Sending request with ${files.length} files...');
      final streamedResponse = await ApiService.postMultipart(
        ApiConstants.incidents,
        fields,
        files,
      );

      final response = await http.Response.fromStream(streamedResponse);

      // Debug logging
      print('📤 Upload response status: ${response.statusCode}');
      print('📤 Upload response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          print('❌ Backend error: ${errorBody}');

          // Extract detailed error messages if available
          String errorMessage =
              errorBody['message'] ?? 'Failed to create incident';

          // If validation errors exist, show them
          if (errorBody['errors'] != null && errorBody['errors'] is List) {
            final errors = errorBody['errors'] as List;
            final errorDetails = errors
                .map((e) => '${e['field']}: ${e['message']}')
                .join(', ');
            errorMessage = 'Validation failed: $errorDetails';
          }

          return {'success': false, 'message': errorMessage};
        } catch (_) {
          return {
            'success': false,
            'message': 'Failed to create incident: ${response.statusCode}',
          };
        }
      }
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Kết nối quá thời gian. Vui lòng thử lại với ảnh/video nhỏ hơn.',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ. Kiểm tra kết nối mạng.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // Get all incidents
  static Future<List<dynamic>> getIncidents() async {
    try {
      final response = await ApiService.get(
        '${ApiConstants.incidents}?limit=100',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching incidents: $e');
      return [];
    }
  }

  // Update incident status
  static Future<Map<String, dynamic>> updateStatus({
    required String incidentId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await ApiService.put(
        '${ApiConstants.incidents}/$incidentId/status',
        {'status': status, if (notes != null) 'notes': notes},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to update status',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Failed to update status: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Approve incident (Leader approves and sends to Admin)
  static Future<Map<String, dynamic>> approveIncident({
    required String incidentId,
    required String priority,
    String? category,
    String? component,
    String? productionLine,
    String? workstation,
    String? department,
    String? leaderNotes,
  }) async {
    try {
      final response = await ApiService.put(
        '${ApiConstants.incidents}/$incidentId/status',
        {'status': 'assigned', 'notes': leaderNotes ?? 'Approved by Leader'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to approve incident',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Failed to approve incident: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Return incident to user
  static Future<Map<String, dynamic>> returnToUser({
    required String incidentId,
    required String reason,
  }) async {
    return updateStatus(
      incidentId: incidentId,
      status: 'pending',
      notes: 'Returned: $reason',
    );
  }

  // Cancel incident
  static Future<Map<String, dynamic>> cancelIncident({
    required String incidentId,
    String? reason,
  }) async {
    return updateStatus(
      incidentId: incidentId,
      status: 'cancelled',
      notes: reason ?? 'Cancelled by Leader',
    );
  }

  // Get all departments
  static Future<List<Map<String, dynamic>>> getDepartments() async {
    try {
      final response = await ApiService.get('/api/departments');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }

  // Assign department to incident (Leader dispatch)
  static Future<Map<String, dynamic>> assignDepartment({
    required String incidentId,
    required String departmentId,
    String? notes,
  }) async {
    try {
      final response = await ApiService.post(
        '${ApiConstants.incidents}/$incidentId/assign-departments',
        {
          'departments': [
            {'department_id': departmentId},
          ],
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to assign department',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Failed to assign department: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
