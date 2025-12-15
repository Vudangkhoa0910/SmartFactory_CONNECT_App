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

  ReportModel({
    required this.id,
    required this.title,
    required this.location,
    required this.priority,
    this.category,
    this.description,
    required this.status,
    this.department,
    this.reporterName, // Add this
    required this.createdDate,
    this.completedDate,
    this.rating,
    this.attachments,
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
    );
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
