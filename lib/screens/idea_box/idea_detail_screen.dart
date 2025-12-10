import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/idea_box_model.dart';
import '../../services/idea_service.dart';
import '../../components/loading_infinity.dart';
import '../../utils/toast_utils.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

/// Màn hình chi tiết góp ý
/// Hiển thị timeline xử lý và cho phép vote mức độ hài lòng
class IdeaDetailScreen extends StatefulWidget {
  final IdeaBoxItem idea;

  const IdeaDetailScreen({super.key, required this.idea});

  @override
  State<IdeaDetailScreen> createState() => _IdeaDetailScreenState();
}

class _IdeaDetailScreenState extends State<IdeaDetailScreen> {
  int _selectedRating = 0;
  final _feedbackController = TextEditingController();
  final IdeaService _ideaService = IdeaService();
  late IdeaBoxItem _idea;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _idea = widget.idea;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final updatedIdea = await _ideaService.getIdeaDetail(_idea.id);
      if (mounted) {
        setState(() {
          _idea = updatedIdea;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching idea detail: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: CustomRefreshIndicator(
                onRefresh: _fetchDetail,
                builder:
                    (
                      BuildContext context,
                      Widget child,
                      IndicatorController controller,
                    ) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          if (!controller.isIdle)
                            Positioned(
                              top: 10.0 * controller.value,
                              child: const SizedBox(
                                height: 80,
                                width: 80,
                                child: LoadingInfinity(size: 80),
                              ),
                            ),
                          Transform.translate(
                            offset: Offset(0, 100.0 * controller.value),
                            child: child,
                          ),
                        ],
                      );
                    },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 20),
                      _buildIdeaDetails(),
                      const SizedBox(height: 20),
                      if (_idea.attachments.isNotEmpty) ...[
                        _buildAttachments(),
                        const SizedBox(height: 20),
                      ],
                      _buildProcessTimeline(),
                      const SizedBox(height: 20),
                      if (_idea.status == IdeaStatus.completed &&
                          _idea.satisfactionRating == null)
                        _buildSatisfactionRating(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.gray900,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  _idea.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: LoadingInfinity(size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray500.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brand50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _idea.issueType.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brand500.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _idea.status.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _idea.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppColors.gray600),
              const SizedBox(width: 6),
              Text(
                _formatDate(_idea.createdAt),
                style: const TextStyle(fontSize: 13, color: AppColors.gray700),
              ),
              if (_idea.difficultyLevel != null) ...[
                const SizedBox(width: 16),
                const Icon(Icons.speed, size: 16, color: AppColors.gray600),
                const SizedBox(width: 6),
                Text(
                  _idea.difficultyLevel!.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (_idea.boxType == IdeaBoxType.white) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: AppColors.gray600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _buildReporterLine(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (_idea.currentHandlerName != null &&
              _idea.currentHandlerName!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.manage_accounts_outlined,
                  size: 18,
                  color: AppColors.gray600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _buildHandlerLine(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIdeaDetails() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand500.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: AppColors.brand500,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.ideaInfo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _idea.content,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.gray700,
              height: 1.6,
            ),
          ),
          if (_idea.expectedBenefit != null &&
              _idea.expectedBenefit!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.trending_up, size: 20, color: AppColors.brand500),
                const SizedBox(width: 8),
                Text(
                  l10n.ideaBenefit,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _idea.expectedBenefit!,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.gray700,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildReporterLine() {
    final name = _idea.senderName ?? 'Không rõ người gửi';
    final code = _idea.senderEmployeeId;
    final dept = _idea.senderDepartment;

    final parts = <String>[name];
    if (code != null && code.isNotEmpty) parts.add('• $code');
    if (dept != null && dept.isNotEmpty) parts.add('• $dept');
    return parts.join(' ');
  }

  String _buildHandlerLine() {
    final handler = _idea.currentHandlerName ?? '';
    final role = _idea.currentHandlerRole;
    if (role != null && role.isNotEmpty) {
      return '$handler • $role';
    }
    return handler;
  }

  // _buildSenderInfo removed; reporter info đã đưa lên status card.

  Widget _buildAttachments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file, size: 20, color: AppColors.brand500),
            const SizedBox(width: 8),
            const Text(
              'Tài liệu đính kèm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _idea.attachments.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gray300.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _idea.attachments[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.gray100,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppColors.gray400,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.transparent,
                                AppColors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.imageLabel(index + 1),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProcessTimeline() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand500.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, size: 20, color: AppColors.brand500),
              const SizedBox(width: 8),
              Text(
                l10n.ideaStatus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_idea.processLogs.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.pending_actions,
                      size: 48,
                      color: AppColors.gray300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noIdeaComments,
                      style: TextStyle(fontSize: 14, color: AppColors.gray500),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _idea.processLogs.length,
              itemBuilder: (context, index) {
                final log = _idea.processLogs[index];
                final isLast = index == _idea.processLogs.length - 1;
                return _buildTimelineItem(log, isLast);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(IdeaProcessLog log, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getStatusColor(log.statusChange).withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getStatusColor(log.statusChange),
                  width: 2,
                ),
              ),
              child: Icon(
                _getStatusIcon(log.statusChange),
                size: 16,
                color: _getStatusColor(log.statusChange),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 60, color: AppColors.gray200),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.statusChange.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                    ),
                    Text(
                      _formatDateTime(log.timestamp),
                      style: TextStyle(fontSize: 12, color: AppColors.gray500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.handlerRole} - ${log.handlerName}',
                  style: TextStyle(fontSize: 13, color: AppColors.gray600),
                ),
                if (log.comment.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      log.comment,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                if (log.escalatedTo != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.orange700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Chuyển đến ${log.escalatedTo}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.orange700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSatisfactionRating() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand500.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_outline, size: 24, color: AppColors.warning500),
              const SizedBox(width: 8),
              Text(
                l10n.reviewIdea,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.addIdeaComment,
            style: TextStyle(fontSize: 14, color: AppColors.gray600),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    _selectedRating > index ? Icons.star : Icons.star_border,
                    size: 40,
                    color: AppColors.warning500,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _feedbackController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.black),
            decoration: const InputDecoration(
              hintText: 'Nhận xét của bạn (tùy chọn)',
              hintStyle: TextStyle(color: AppColors.gray400),
              filled: true,
              fillColor: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedRating > 0 ? _submitRating : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand500,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.gray200,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.sendIdeaComment,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(IdeaStatus status) {
    switch (status) {
      case IdeaStatus.submitted:
        return AppColors.gray500;
      case IdeaStatus.underReview:
        return AppColors.blueLight500;
      case IdeaStatus.escalated:
        return AppColors.orange500;
      case IdeaStatus.approved:
        return AppColors.success500;
      case IdeaStatus.rejected:
        return AppColors.error500;
      case IdeaStatus.implementing:
        return AppColors.warning500;
      case IdeaStatus.completed:
        return AppColors.success600;
    }
  }

  IconData _getStatusIcon(IdeaStatus status) {
    switch (status) {
      case IdeaStatus.submitted:
        return Icons.send;
      case IdeaStatus.underReview:
        return Icons.visibility;
      case IdeaStatus.escalated:
        return Icons.arrow_upward;
      case IdeaStatus.approved:
        return Icons.check_circle;
      case IdeaStatus.rejected:
        return Icons.cancel;
      case IdeaStatus.implementing:
        return Icons.engineering;
      case IdeaStatus.completed:
        return Icons.done_all;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _submitRating() {
    // TODO: Gọi API để lưu đánh giá
    final l10n = AppLocalizations.of(context)!;
    ToastUtils.showSuccess(l10n.success);

    setState(() {
      // Update local state
    });
  }
}
