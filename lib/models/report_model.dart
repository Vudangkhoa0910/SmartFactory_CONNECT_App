import 'dart:convert';
import 'attachment_model.dart';

enum ReportStatus {
  pending, // Chờ duyệt
  processing, // Đang xử lý
  completed, // Hoàn thành
  closed, // Đã đóng
}

enum ReportPriority {
  low, // Thấp
  medium, // Trung bình
  high, // Cao
  urgent, // Khẩn cấp
}

enum ReportCategory {
  technical, // Kỹ thuật
  safety, // An toàn
  quality, // Chất lượng
  process, // Quy trình
  personnel, // Nhân sự
  other, // Khác
}

/// Similar incident from RAG search results
class SimilarIncident {
  final String id;
  final String title;
  final String? description;
  final double similarity;
  final String? status;
  final String? departmentName;
  final DateTime? createdAt;

  SimilarIncident({
    required this.id,
    required this.title,
    this.description,
    required this.similarity,
    this.status,
    this.departmentName,
    this.createdAt,
  });

  factory SimilarIncident.fromJson(Map<String, dynamic> json) {
    return SimilarIncident(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString(),
      departmentName: json['department_name']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  /// Similarity as percentage (0-100)
  int get similarityPercent => (similarity * 100).round();
}

/// RAG AI suggestion for department assignment
class RAGSuggestion {
  final String departmentId;
  final String departmentName;
  final double confidence;
  final bool autoAssign;
  final List<SimilarIncident> similarIncidents;

  RAGSuggestion({
    required this.departmentId,
    required this.departmentName,
    required this.confidence,
    required this.autoAssign,
    this.similarIncidents = const [],
  });

  factory RAGSuggestion.fromJson(Map<String, dynamic> json) {
    // Parse similar incidents
    List<SimilarIncident> incidents = [];
    if (json['similar_incidents'] != null &&
        json['similar_incidents'] is List) {
      incidents = (json['similar_incidents'] as List)
          .map((item) => SimilarIncident.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return RAGSuggestion(
      departmentId: json['department_id']?.toString() ?? '',
      departmentName: json['department_name']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      autoAssign: json['auto_assign'] == true,
      similarIncidents: incidents,
    );
  }

  /// Confidence as percentage (0-100)
  int get confidencePercent => (confidence * 100).round();

  /// Check if there are similar incidents to show
  bool get hasSimilarIncidents => similarIncidents.isNotEmpty;
}

class ReportModel {
  final String id;
  final String title;
  final String location;
  final ReportPriority priority;
  final ReportCategory? category;
  final String? description;
  final ReportStatus status;
  final String? department;
  final String? reporterName;
  final DateTime createdDate;
  final DateTime? completedDate;
  final double? rating;
  final List<AttachmentModel>? attachments;
  final RAGSuggestion? ragSuggestion;

  ReportModel({
    required this.id,
    required this.title,
    required this.location,
    required this.priority,
    this.category,
    this.description,
    required this.status,
    this.department,
    this.reporterName,
    required this.createdDate,
    this.completedDate,
    this.rating,
    this.attachments,
    this.ragSuggestion,
  });

  // Helper methods - get enum key names for translation in UI
  String get priorityKey => priority.name;
  String get statusKey => status.name;
  String get categoryKey => category?.name ?? '';

  // Backward compatibility - return Vietnamese labels (to be deprecated)
  String get priorityLabel {
    switch (priority) {
      case ReportPriority.low:
        return 'Thấp';
      case ReportPriority.medium:
        return 'Trung bình';
      case ReportPriority.high:
        return 'Cao';
      case ReportPriority.urgent:
        return 'Khẩn cấp';
    }
  }

  String get statusLabel {
    switch (status) {
      case ReportStatus.pending:
        return 'Chờ duyệt';
      case ReportStatus.processing:
        return 'Đang xử lý';
      case ReportStatus.completed:
        return 'Hoàn thành';
      case ReportStatus.closed:
        return 'Đã đóng';
    }
  }

  String get categoryLabel {
    if (category == null) return 'Khác';
    switch (category!) {
      case ReportCategory.technical:
        return 'Kỹ thuật';
      case ReportCategory.safety:
        return 'An toàn';
      case ReportCategory.quality:
        return 'Chất lượng';
      case ReportCategory.process:
        return 'Quy trình';
      case ReportCategory.personnel:
        return 'Nhân sự';
      case ReportCategory.other:
        return 'Khác';
    }
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      priority: _parsePriority(json['priority']),
      category: _parseCategory(json['incident_type']),
      description: json['description'],
      status: _parseStatus(json['status']),
      department: json['department_name'],
      reporterName: json['reporter_name'],
      createdDate: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at']) ?? DateTime.now())
          : DateTime.now(),
      completedDate: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'])
          : null,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      attachments: AttachmentModel.parseList(json['attachments']),
      ragSuggestion: _parseRagSuggestion(json['rag_suggestion']),
    );
  }

  static RAGSuggestion? _parseRagSuggestion(dynamic ragJson) {
    if (ragJson == null) return null;

    // Handle case where rag_suggestion is stored as JSON string
    Map<String, dynamic>? data;
    if (ragJson is String) {
      try {
        data = Map<String, dynamic>.from(
          (ragJson.isNotEmpty) ? _decodeJson(ragJson) : {},
        );
      } catch (e) {
        print('Error parsing rag_suggestion string: $e');
        return null;
      }
    } else if (ragJson is Map) {
      data = Map<String, dynamic>.from(ragJson);
    }

    if (data == null || data.isEmpty) return null;
    if (data['department_id'] == null) return null;

    return RAGSuggestion.fromJson(data);
  }

  static dynamic _decodeJson(String jsonStr) {
    // Parse JSON string to Map
    try {
      return jsonDecode(jsonStr);
    } catch (e) {
      print('Error decoding JSON: $e');
      return null;
    }
  }

  static ReportPriority _parsePriority(String? priority) {
    switch (priority) {
      case 'low':
        return ReportPriority.low;
      case 'medium':
        return ReportPriority.medium;
      case 'high':
        return ReportPriority.high;
      case 'critical':
        return ReportPriority.urgent;
      default:
        return ReportPriority.medium;
    }
  }

  static ReportCategory _parseCategory(String? category) {
    switch (category) {
      case 'equipment':
        return ReportCategory.technical;
      case 'safety':
        return ReportCategory.safety;
      case 'quality':
        return ReportCategory.quality;
      default:
        return ReportCategory.other;
    }
  }

  static ReportStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return ReportStatus.pending;
      case 'assigned':
      case 'in_progress':
        return ReportStatus.processing;
      case 'resolved':
        return ReportStatus.completed;
      case 'closed':
      case 'cancelled':
        return ReportStatus.closed;
      default:
        return ReportStatus.pending;
    }
  }
}
