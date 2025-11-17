import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import 'report_form_screen.dart';
import 'report_detail_screen.dart';
import '../../models/report_model.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  // Sample data
  List<ReportModel> get _reports => [
    ReportModel(
      id: 'SC-1024',
      title: 'Máy dập Line 3 bị kẹt',
      location: 'Line 3 - Khu vực sản xuất',
      priority: ReportPriority.high,
      category: ReportCategory.technical,
      status: ReportStatus.processing,
      department: 'Bộ phận bảo trì',
      createdDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ReportModel(
      id: 'SC-1021',
      title: 'Rò rỉ khí nén',
      location: 'Line 5 - Máy hàn tự động',
      priority: ReportPriority.urgent,
      category: ReportCategory.safety,
      status: ReportStatus.completed,
      department: 'Bộ phận kỹ thuật',
      createdDate: DateTime.now().subtract(const Duration(days: 5)),
      completedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ReportModel(
      id: 'SC-1015',
      title: 'Hỏng cảm biến nhiệt',
      location: 'Line 2 - Máy sơn',
      priority: ReportPriority.medium,
      category: ReportCategory.technical,
      status: ReportStatus.closed,
      department: 'Bộ phận điện tử',
      createdDate: DateTime.now().subtract(const Duration(days: 10)),
      completedDate: DateTime.now().subtract(const Duration(days: 7)),
      rating: 4.5,
    ),
  ];

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.processing:
        return AppColors.orange500;
      case ReportStatus.completed:
        return AppColors.success500;
      case ReportStatus.closed:
        return AppColors.gray400;
    }
  }

  Color _getPriorityColor(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.low:
        return AppColors.success500;
      case ReportPriority.medium:
        return AppColors.blueLight500;
      case ReportPriority.high:
        return AppColors.orange500;
      case ReportPriority.urgent:
        return AppColors.error500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.appBackgroundGradient,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Main content - Report history list
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _reports.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: AppColors.gray300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có báo cáo sự cố nào.',
                                  style: TextStyle(
                                    color: AppColors.gray500,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _reports.length,
                            itemBuilder: (context, index) {
                              final report = _reports[index];
                              return _ReportCard(
                                report: report,
                                statusColor: _getStatusColor(report.status),
                                priorityColor: _getPriorityColor(
                                  report.priority,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReportDetailScreen(report: report),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Action Button
          Positioned(
            bottom: 100,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brand500.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ReportFormScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const curve = Curves.easeInOutCubic;

                            var scaleTween = Tween<double>(
                              begin: 0.85,
                              end: 1.0,
                            ).chain(CurveTween(curve: curve));
                            var scaleAnimation = animation.drive(scaleTween);

                            var fadeTween = Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).chain(CurveTween(curve: curve));
                            var fadeAnimation = animation.drive(fadeTween);

                            var radiusTween = Tween<double>(
                              begin: 40.0,
                              end: 0.0,
                            ).chain(CurveTween(curve: curve));
                            var radiusAnimation = animation.drive(radiusTween);

                            return ScaleTransition(
                              scale: scaleAnimation,
                              child: FadeTransition(
                                opacity: fadeAnimation,
                                child: AnimatedBuilder(
                                  animation: radiusAnimation,
                                  builder: (context, child) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        radiusAnimation.value,
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: child,
                                ),
                              ),
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                backgroundColor: AppColors.brand500,
                elevation: 0,
                shape: CircleBorder(),
                child: Icon(Icons.add, color: AppColors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final Color statusColor;
  final Color priorityColor;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.statusColor,
    required this.priorityColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with ID and priority
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        report.id,
                        style: TextStyle(
                          color: AppColors.gray700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        report.priorityLabel,
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        report.statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  report.title,
                  style: TextStyle(
                    color: AppColors.gray800,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColors.gray400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.location,
                        style: TextStyle(
                          color: AppColors.gray600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Department and Date
                Row(
                  children: [
                    if (report.department != null) ...[
                      Icon(Icons.business, size: 16, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      Text(
                        report.department!,
                        style: TextStyle(
                          color: AppColors.gray600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${report.createdDate.day}/${report.createdDate.month}/${report.createdDate.year}',
                      style: TextStyle(color: AppColors.gray600, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
