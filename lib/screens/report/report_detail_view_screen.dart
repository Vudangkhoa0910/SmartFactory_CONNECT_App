import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../utils/toast_utils.dart';
import '../../models/report_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_toggle_button.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return AppColors.error500;
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.gray800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.reportDetail,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status Card
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          report.title,
                          style: TextStyle(
                            color: AppColors.gray800,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(
                                report.priority,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              report.priorityLabel,
                              style: TextStyle(
                                color: _getPriorityColor(report.priority),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                report.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              report.statusLabel,
                              style: TextStyle(
                                color: _getStatusColor(report.status),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reporter Name
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        report.reporterName ?? 'N/A',
                        style: TextStyle(
                          color: AppColors.gray700,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details Card
            _buildDetailCard(
              title: l10n.detailInfo,
              children: [
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: l10n.locationDevice,
                  value: report.location,
                ),
                if (report.category != null)
                  _buildDetailRow(
                    icon: Icons.category,
                    label: l10n.category,
                    value: report.categoryLabel,
                  ),
                if (report.department != null)
                  _buildDetailRow(
                    icon: Icons.business,
                    label: l10n.responsibleDepartment,
                    value: report.department!,
                  ),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: l10n.createdAt,
                  value:
                      '${report.createdDate.day}/${report.createdDate.month}/${report.createdDate.year}',
                ),
                if (report.completedDate != null)
                  _buildDetailRow(
                    icon: Icons.check_circle,
                    label: l10n.completedDate,
                    value:
                        '${report.completedDate!.day}/${report.completedDate!.month}/${report.completedDate!.year}',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Description Card
            if (report.description != null) ...[
              _buildDetailCard(
                title: l10n.description,
                children: [
                  Text(
                    report.description!,
                    style: TextStyle(
                      color: AppColors.gray700,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Attachments Card (if any)
            if (report.attachments != null &&
                report.attachments!.isNotEmpty) ...[
              _buildDetailCard(
                title: l10n.attachments,
                children: [
                  ...report.attachments!.map(
                    (attachment) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            attachment.isImage
                                ? Icons.image
                                : attachment.isAudio
                                    ? Icons.audiotrack
                                    : Icons.attachment,
                            size: 20,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              attachment.originalName,
                              style: TextStyle(
                                color: AppColors.gray700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Rating Card (if rated)
            if (report.rating != null) ...[
              _buildDetailCard(
                title: l10n.ratingQuality,
                children: [
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < report.rating!.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.orange500,
                          size: 28,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${report.rating}/5.0',
                        style: TextStyle(
                          color: AppColors.gray800,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Action Button (if status is completed and not rated)
            if (report.status == ReportStatus.completed &&
                report.rating == null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showRatingDialog(context, l10n);
                  },
                  icon: Icon(Icons.star_border, size: 20),
                  label: Text(
                    l10n.ratingQuality,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand500,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.gray800,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.gray400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: AppColors.gray500, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppColors.gray800,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, AppLocalizations l10n) {
    double rating = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.ratingQuality,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              report.title,
              style: TextStyle(color: AppColors.gray600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: AppColors.orange500,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1.0;
                        });
                      },
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.commentOptional,
                hintStyle: TextStyle(color: AppColors.gray400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppColors.gray600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Submit rating
              Navigator.pop(context);
              ToastUtils.showSuccess(l10n.thankYouForRating);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.submitRating),
          ),
        ],
      ),
    );
  }
}
