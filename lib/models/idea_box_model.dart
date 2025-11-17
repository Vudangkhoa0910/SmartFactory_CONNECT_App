/// Model cho hệ thống Hòm thư góp ý (Idea Box)
/// Hỗ trợ cả Hòm thư trắng (công khai) và Hòm thư hồng (ẩn danh)

enum IdeaBoxType {
  white, // Hòm thư trắng - công khai
  pink, // Hòm thư hồng - ẩn danh
}

enum IssueType {
  quality, // Chất lượng
  safety, // An toàn
  performance, // Hiệu suất
  energySaving, // Tiết kiệm năng lượng
  process, // Quy trình
  workEnvironment, // Môi trường làm việc
  welfare, // Phúc lợi
  pressure, // Áp lực / nhân sự
  psychologicalSafety, // An toàn tâm lý
  fairness, // Công bằng - công việc
  other, // Khác
}

enum DifficultyLevel {
  easy, // Dễ
  medium, // Trung bình
  hard, // Khó
  veryHard, // Rất khó
}

enum IdeaStatus {
  submitted, // Đã gửi
  underReview, // Đang xem xét
  escalated, // Đã chuyển cấp trên
  approved, // Đã phê duyệt
  rejected, // Đã từ chối
  implementing, // Đang triển khai cải tiến
  completed, // Hoàn thành
}

class IdeaBoxItem {
  final String id;
  final IdeaBoxType boxType;
  final IssueType issueType;
  final String title;
  final String content;
  final List<String> attachments; // URLs của ảnh/video
  final DateTime createdAt;
  final IdeaStatus status;
  final DifficultyLevel? difficultyLevel;
  
  // Thông tin người gửi - chỉ hiển thị nếu là Hòm thư trắng
  final String? senderName;
  final String? senderEmployeeId;
  final String? senderDepartment;
  final String? senderAvatar;
  
  // Thông tin xử lý
  final List<IdeaProcessLog> processLogs;
  final String? currentHandlerName;
  final String? currentHandlerRole; // Supervisor, Manager, GM, Admin
  
  // Đánh giá cuối cùng
  final int? satisfactionRating; // 1-5 sao
  final String? satisfactionComment;

  IdeaBoxItem({
    required this.id,
    required this.boxType,
    required this.issueType,
    required this.title,
    required this.content,
    required this.attachments,
    required this.createdAt,
    required this.status,
    this.difficultyLevel,
    this.senderName,
    this.senderEmployeeId,
    this.senderDepartment,
    this.senderAvatar,
    required this.processLogs,
    this.currentHandlerName,
    this.currentHandlerRole,
    this.satisfactionRating,
    this.satisfactionComment,
  });

  factory IdeaBoxItem.fromJson(Map<String, dynamic> json) {
    return IdeaBoxItem(
      id: json['id'],
      boxType: IdeaBoxType.values.firstWhere(
        (e) => e.toString() == 'IdeaBoxType.${json['boxType']}',
      ),
      issueType: IssueType.values.firstWhere(
        (e) => e.toString() == 'IssueType.${json['issueType']}',
      ),
      title: json['title'],
      content: json['content'],
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      status: IdeaStatus.values.firstWhere(
        (e) => e.toString() == 'IdeaStatus.${json['status']}',
      ),
      difficultyLevel: json['difficultyLevel'] != null
          ? DifficultyLevel.values.firstWhere(
              (e) => e.toString() == 'DifficultyLevel.${json['difficultyLevel']}',
            )
          : null,
      senderName: json['senderName'],
      senderEmployeeId: json['senderEmployeeId'],
      senderDepartment: json['senderDepartment'],
      senderAvatar: json['senderAvatar'],
      processLogs: (json['processLogs'] as List?)
              ?.map((log) => IdeaProcessLog.fromJson(log))
              .toList() ??
          [],
      currentHandlerName: json['currentHandlerName'],
      currentHandlerRole: json['currentHandlerRole'],
      satisfactionRating: json['satisfactionRating'],
      satisfactionComment: json['satisfactionComment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'boxType': boxType.toString().split('.').last,
      'issueType': issueType.toString().split('.').last,
      'title': title,
      'content': content,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'difficultyLevel': difficultyLevel?.toString().split('.').last,
      'senderName': senderName,
      'senderEmployeeId': senderEmployeeId,
      'senderDepartment': senderDepartment,
      'senderAvatar': senderAvatar,
      'processLogs': processLogs.map((log) => log.toJson()).toList(),
      'currentHandlerName': currentHandlerName,
      'currentHandlerRole': currentHandlerRole,
      'satisfactionRating': satisfactionRating,
      'satisfactionComment': satisfactionComment,
    };
  }
}

class IdeaProcessLog {
  final String id;
  final DateTime timestamp;
  final String handlerName;
  final String handlerRole;
  final IdeaStatus statusChange;
  final String comment;
  final String? escalatedTo; // Role của người được chuyển tiếp

  IdeaProcessLog({
    required this.id,
    required this.timestamp,
    required this.handlerName,
    required this.handlerRole,
    required this.statusChange,
    required this.comment,
    this.escalatedTo,
  });

  factory IdeaProcessLog.fromJson(Map<String, dynamic> json) {
    return IdeaProcessLog(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      handlerName: json['handlerName'],
      handlerRole: json['handlerRole'],
      statusChange: IdeaStatus.values.firstWhere(
        (e) => e.toString() == 'IdeaStatus.${json['statusChange']}',
      ),
      comment: json['comment'],
      escalatedTo: json['escalatedTo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'handlerName': handlerName,
      'handlerRole': handlerRole,
      'statusChange': statusChange.toString().split('.').last,
      'comment': comment,
      'escalatedTo': escalatedTo,
    };
  }
}

// Helper extensions để lấy nhãn tiếng Việt
extension IssueTypeExtension on IssueType {
  String get label {
    switch (this) {
      case IssueType.quality:
        return 'Chất lượng';
      case IssueType.safety:
        return 'An toàn';
      case IssueType.performance:
        return 'Hiệu suất';
      case IssueType.energySaving:
        return 'Tiết kiệm năng lượng';
      case IssueType.process:
        return 'Quy trình';
      case IssueType.workEnvironment:
        return 'Môi trường làm việc';
      case IssueType.welfare:
        return 'Phúc lợi';
      case IssueType.pressure:
        return 'Áp lực / Nhân sự';
      case IssueType.psychologicalSafety:
        return 'An toàn tâm lý';
      case IssueType.fairness:
        return 'Công bằng - Công việc';
      case IssueType.other:
        return 'Khác';
    }
  }
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get label {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Dễ';
      case DifficultyLevel.medium:
        return 'Trung bình';
      case DifficultyLevel.hard:
        return 'Khó';
      case DifficultyLevel.veryHard:
        return 'Rất khó';
    }
  }
}

extension IdeaStatusExtension on IdeaStatus {
  String get label {
    switch (this) {
      case IdeaStatus.submitted:
        return 'Đã gửi';
      case IdeaStatus.underReview:
        return 'Đang xem xét';
      case IdeaStatus.escalated:
        return 'Đã chuyển cấp trên';
      case IdeaStatus.approved:
        return 'Đã phê duyệt';
      case IdeaStatus.rejected:
        return 'Đã từ chối';
      case IdeaStatus.implementing:
        return 'Đang triển khai';
      case IdeaStatus.completed:
        return 'Hoàn thành';
    }
  }
}
