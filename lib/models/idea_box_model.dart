import 'dart:convert';

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
  final String? expectedBenefit; // Lợi ích dự kiến
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
    this.expectedBenefit,
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
    // Helper to parse attachments - supports both GridFS (url) and legacy (path) formats
    List<String> parseAttachments(dynamic attachments) {
      if (attachments == null) return [];
      if (attachments is String) {
        try {
          final List<dynamic> list = jsonDecode(attachments);
          // Support both 'url' (new GridFS) and 'path' (legacy) formats
          return list.map((e) => (e['url'] ?? e['path']) as String).toList();
        } catch (e) {
          return [];
        }
      }
      if (attachments is List) {
        return attachments.map((e) {
          if (e is String) return e;
          // Support both 'url' (new GridFS) and 'path' (legacy) formats
          if (e is Map) return (e['url'] ?? e['path']) as String;
          return '';
        }).toList();
      }
      return [];
    }

    // Helper to parse DifficultyLevel from feasibility_score
    DifficultyLevel? parseDifficulty(dynamic score) {
      if (score == null) return null;
      final int val = score is int
          ? score
          : int.tryParse(score.toString()) ?? 0;
      if (val >= 8) return DifficultyLevel.easy;
      if (val >= 5) return DifficultyLevel.medium;
      if (val >= 3) return DifficultyLevel.hard;
      return DifficultyLevel.veryHard;
    }

    // Helper to parse IdeaBoxType
    IdeaBoxType parseBoxType(String? type) {
      if (type == 'pink') return IdeaBoxType.pink;
      return IdeaBoxType.white;
    }

    // Helper to parse IssueType (category)
    IssueType parseIssueType(String? category) {
      switch (category) {
        case 'quality_improvement':
          return IssueType.quality;
        case 'safety_enhancement':
          return IssueType.safety;
        case 'productivity':
          return IssueType.performance;
        case 'cost_reduction':
          return IssueType.energySaving; // Mapping energy to cost/env
        case 'environment':
          return IssueType.energySaving;
        case 'process_improvement':
          return IssueType.process;
        case 'workplace':
          return IssueType.workEnvironment;
        // Pink box specific types might map to 'other' or specific ones if backend supports them
        // For now mapping them to 'other' or closest match
        case 'welfare':
          return IssueType.welfare; // If backend adds this
        case 'pressure':
          return IssueType.pressure;
        case 'psychological_safety':
          return IssueType.psychologicalSafety;
        case 'fairness':
          return IssueType.fairness;
        default:
          return IssueType.other;
      }
    }

    // Helper to parse IdeaStatus
    IdeaStatus parseStatus(String? status) {
      switch (status) {
        case 'submitted':
        case 'pending':
          return IdeaStatus.submitted;
        case 'under_review':
          return IdeaStatus.underReview;
        case 'escalated':
          return IdeaStatus.escalated;
        case 'approved':
          return IdeaStatus.approved;
        case 'rejected':
          return IdeaStatus.rejected;
        case 'implementing':
          return IdeaStatus.implementing;
        case 'completed':
        case 'implemented':
          return IdeaStatus.completed;
        default:
          return IdeaStatus.submitted;
      }
    }

    // Helper to parse process logs from history and responses
    List<IdeaProcessLog> parseProcessLogs(Map<String, dynamic> json) {
      List<IdeaProcessLog> logs = [];

      // Parse history
      if (json['history'] != null && json['history'] is List) {
        for (var h in json['history']) {
          // Map action to status
          IdeaStatus status;
          String comment = '';
          String? escalatedTo;

          switch (h['action']) {
            case 'submitted':
              status = IdeaStatus.submitted;
              comment = 'Đã gửi góp ý';
              break;
            case 'assigned':
              status = IdeaStatus.underReview;
              comment = 'Đã phân công xử lý';
              break;
            case 'reviewed':
              // Parse details for status
              try {
                final details = h['details'] is String
                    ? jsonDecode(h['details'])
                    : h['details'];
                status = parseStatus(details['new_status']);
                comment = details['review_notes'] ?? 'Đã xem xét';
              } catch (_) {
                status = IdeaStatus.underReview;
                comment = 'Đã xem xét';
              }
              break;
            case 'implemented':
              status = IdeaStatus.implementing;
              comment = 'Đã triển khai';
              break;
            case 'escalated':
              status = IdeaStatus.escalated;
              try {
                final details = h['details'] is String
                    ? jsonDecode(h['details'])
                    : h['details'];
                escalatedTo = details['to_level'];
                comment = 'Đã chuyển cấp trên: $escalatedTo';
              } catch (_) {
                comment = 'Đã chuyển cấp trên';
              }
              break;
            default:
              status = IdeaStatus.underReview;
              comment = h['action'];
          }

          logs.add(
            IdeaProcessLog(
              id: h['id'].toString(),
              timestamp: DateTime.parse(h['created_at']),
              handlerName: h['performed_by_name'] ?? 'Unknown',
              handlerRole: h['role'] ?? 'System',
              statusChange: status,
              comment: comment,
              escalatedTo: escalatedTo,
            ),
          );
        }
      }

      // Parse responses
      if (json['responses'] != null && json['responses'] is List) {
        for (var r in json['responses']) {
          logs.add(
            IdeaProcessLog(
              id: r['id'].toString(),
              timestamp: DateTime.parse(r['created_at']),
              handlerName: r['responder_name'] ?? 'Unknown',
              handlerRole: r['role'] ?? 'User',
              statusChange: IdeaStatus
                  .underReview, // Responses don't necessarily change status
              comment: r['response'] ?? '',
            ),
          );
        }
      }

      // Sort by timestamp descending
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    }

    return IdeaBoxItem(
      id: json['id'].toString(),
      boxType: parseBoxType(json['ideabox_type']),
      issueType: parseIssueType(json['category']),
      title: json['title'] ?? '',
      content: json['description'] ?? '', // Backend uses 'description'
      expectedBenefit: json['expected_benefit'],
      attachments: parseAttachments(json['attachments']),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      status: parseStatus(json['status']),
      difficultyLevel: parseDifficulty(json['feasibility_score']),
      senderName: json['submitter_name'] ?? json['senderName'],
      senderEmployeeId: json['submitter_code'] ?? json['senderEmployeeId'],
      senderDepartment: json['department_name'] ?? json['senderDepartment'],
      senderAvatar: json['senderAvatar'],
      processLogs: parseProcessLogs(json),
      currentHandlerName:
          json['assigned_to_name'] ?? json['currentHandlerName'],
      currentHandlerRole: json['handler_level'] ?? json['currentHandlerRole'],
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
      'expectedBenefit': expectedBenefit,
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

// Helper extensions to get key names for translation in UI
// Use these keys with AppLocalizations in UI screens
extension IssueTypeExtension on IssueType {
  /// Returns the enum key name for i18n lookup
  String get key => name;

  /// Backward compatibility - return Vietnamese label (to be deprecated)
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
        return 'Áp lực / nhân sự';
      case IssueType.psychologicalSafety:
        return 'An toàn tâm lý';
      case IssueType.fairness:
        return 'Công bằng - công việc';
      case IssueType.other:
        return 'Khác';
    }
  }
}

extension DifficultyLevelExtension on DifficultyLevel {
  /// Returns the enum key name for i18n lookup
  String get key => name;

  /// Backward compatibility - return Vietnamese label (to be deprecated)
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
  /// Returns the enum key name for i18n lookup
  String get key => name;

  /// Backward compatibility - return Vietnamese label (to be deprecated)
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
