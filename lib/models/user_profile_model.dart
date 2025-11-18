enum Gender { male, female, other }

enum UserRole { worker, sv, mgr, gm, admin }

enum WorkStatus { active, onLeave, resigned }

enum ShiftType { shift1, shift2, shift3 }

enum ActivityType { reportIncident, submitSuggestion, rateImprovement, other }

enum ActivityStatus { processing, completed, rejected }

class UserActivity {
  final String id;
  final ActivityType type;
  final DateTime timestamp;
  final ActivityStatus status;
  final String? handledBy;
  final String? note;
  final String? title;

  UserActivity({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.status,
    this.handledBy,
    this.note,
    this.title,
  });
}

class UserProfile {
  // Thông tin cá nhân
  final String id;
  final String fullName;
  final String employeeId;
  final Gender gender;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String email;
  final String? address;
  final String? avatarUrl;

  // Thông tin công việc
  final UserRole role;
  final String department;
  final DateTime joinDate;
  final ShiftType shift;
  final WorkStatus workStatus;

  // Lịch sử hoạt động
  final List<UserActivity> activities;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.employeeId,
    required this.gender,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.email,
    this.address,
    this.avatarUrl,
    required this.role,
    required this.department,
    required this.joinDate,
    required this.shift,
    required this.workStatus,
    this.activities = const [],
  });

  // Check permissions
  bool get canApprove => role != UserRole.worker;
  bool get canClassifySuggestions => role != UserRole.worker;
  bool get canEditEmployeeInfo => role == UserRole.admin;
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Nam';
      case Gender.female:
        return 'Nữ';
      case Gender.other:
        return 'Khác';
    }
  }
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.worker:
        return 'Worker';
      case UserRole.sv:
        return 'Team Leader';
      case UserRole.mgr:
        return 'Mgr';
      case UserRole.gm:
        return 'GM';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

extension WorkStatusExtension on WorkStatus {
  String get displayName {
    switch (this) {
      case WorkStatus.active:
        return 'Đang làm';
      case WorkStatus.onLeave:
        return 'Tạm nghỉ';
      case WorkStatus.resigned:
        return 'Nghỉ việc';
    }
  }
}

extension ShiftTypeExtension on ShiftType {
  String get displayName {
    switch (this) {
      case ShiftType.shift1:
        return 'Ca 1';
      case ShiftType.shift2:
        return 'Ca 2';
      case ShiftType.shift3:
        return 'Ca 3';
    }
  }
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.reportIncident:
        return 'Gửi báo cáo sự cố';
      case ActivityType.submitSuggestion:
        return 'Gửi góp ý';
      case ActivityType.rateImprovement:
        return 'Đánh giá tiến độ';
      case ActivityType.other:
        return 'Khác';
    }
  }
}

extension ActivityStatusExtension on ActivityStatus {
  String get displayName {
    switch (this) {
      case ActivityStatus.processing:
        return 'Đang xử lý';
      case ActivityStatus.completed:
        return 'Đã xử lý';
      case ActivityStatus.rejected:
        return 'Bị từ chối';
    }
  }
}
