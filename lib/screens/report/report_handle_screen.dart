import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_toggle_button.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.gray800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userRole == 'leader' ? l10n.handleIncident : l10n.incidentDetail,
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          LanguageToggleIconButton(),
          SizedBox(width: 8),
        ],
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
                      'Leader view: ${l10n.leaderCanAssignAndUpdate}',
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
                      'User view: ${l10n.userCanOnlyViewProgress}',
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
