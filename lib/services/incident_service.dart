import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'api_constants.dart';

class IncidentService {
  // Create new incident
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
      final fields = {
        'title': title,
        'description': description,
        'location': location,
        'priority': priority,
        'incident_type': incidentType,
      };

      List<http.MultipartFile> files = [];

      if (images != null) {
        for (var image in images) {
          files.add(await http.MultipartFile.fromPath('files', image.path));
        }
      }

      if (videos != null) {
        for (var video in videos) {
          files.add(await http.MultipartFile.fromPath('files', video.path));
        }
      }

      if (audioPath != null) {
        files.add(await http.MultipartFile.fromPath('files', audioPath));
      }

      final streamedResponse = await ApiService.postMultipart(
        ApiConstants.incidents,
        fields,
        files,
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to create incident',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Failed to create incident: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
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
}
