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
}
