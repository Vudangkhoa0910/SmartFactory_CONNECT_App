enum ReportStatus {
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
  final String? reporterName; // Add this
  final DateTime createdDate;
  final DateTime? completedDate;
  final double? rating;
  final List<String>? attachments;

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

  // Helper methods
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
      case ReportStatus.processing:
        return 'Đang xử lý';
      case ReportStatus.completed:
        return 'Hoàn thành';
      case ReportStatus.closed:
        return 'Đã đóng';
    }
  }

  String get categoryLabel {
    if (category == null) return '';
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
      reporterName: json['reporter_name'], // Add this
      createdDate: DateTime.parse(json['created_at']),
      completedDate: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      // attachments handling might need adjustment based on actual JSON structure
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
      case 'resolved':
        return ReportStatus.completed;
      case 'closed':
      case 'cancelled':
        return ReportStatus.closed;
      default:
        return ReportStatus.processing;
    }
  }
}
