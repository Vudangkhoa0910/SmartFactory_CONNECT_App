import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Screen để xử lý sự cố với 2 chức vụ: User và Leader
/// User: Xem chi tiết sự cố, theo dõi tiến độ
/// Leader: Xem chi tiết + Phân công xử lý + Cập nhật trạng thái
class ReportHandleScreen extends StatefulWidget {
  final String reportId;
  final String userRole; // 'user' hoặc 'leader'

  const ReportHandleScreen({
    super.key,
    required this.reportId,
    required this.userRole,
  });

  @override
  State<ReportHandleScreen> createState() => _ReportHandleScreenState();
}

class _ReportHandleScreenState extends State<ReportHandleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.gray800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userRole == 'leader' ? 'Xử lý sự cố' : 'Chi tiết sự cố',
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report ID: ${widget.reportId}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'User Role: ${widget.userRole}',
                  style: TextStyle(fontSize: 14, color: AppColors.gray600),
                ),
                const SizedBox(height: 24),
                if (widget.userRole == 'leader')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.brand50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Leader view: Có thể phân công xử lý, cập nhật trạng thái',
                      style: TextStyle(fontSize: 14, color: AppColors.brand500),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'User view: Chỉ xem chi tiết và theo dõi tiến độ',
                      style: TextStyle(fontSize: 14, color: AppColors.gray700),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
