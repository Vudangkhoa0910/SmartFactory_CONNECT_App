import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/idea_box_model.dart';
import '../../services/idea_service.dart';
import '../../widgets/text_field_with_mic.dart';

/// Màn hình chi tiết góp ý
/// Hiển thị timeline xử lý và cho phép vote mức độ hài lòng
class IdeaDetailScreen extends StatefulWidget {
  final IdeaBoxItem idea;

  const IdeaDetailScreen({
    super.key,
    required this.idea,
  });

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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchDetail,
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
                        _buildSenderInfo(),
                        const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.gray900,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _idea.boxType == IdeaBoxType.white
                          ? Icons.inbox_outlined
                          : Icons.favorite_border,
                      size: 16,
                      color: _idea.boxType == IdeaBoxType.white
                          ? AppColors.brand500
                          : AppColors.themePink500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _idea.boxType == IdeaBoxType.white
                          ? 'Hòm trắng'
                          : 'Hòm hồng',
                      style: TextStyle(
                        fontSize: 14,
                        color: _idea.boxType == IdeaBoxType.white
                            ? AppColors.brand600
                            : AppColors.themePink500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chi tiết góp ý',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: () {
                // TODO: Share functionality
              },
              icon: const Icon(Icons.share_outlined),
              color: AppColors.gray600,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brand500,
            AppColors.brand400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand500.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _idea.issueType.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
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
              color: AppColors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.white,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(_idea.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.white,
                ),
              ),
              if (_idea.difficultyLevel != null) ...[
                const SizedBox(width: 16),
                const Icon(
                  Icons.speed,
                  size: 16,
                  color: AppColors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  _idea.difficultyLevel!.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.white,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaDetails() {
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
              const Text(
                'Nội dung chi tiết',
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
          if (_idea.expectedBenefit != null && _idea.expectedBenefit!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: AppColors.brand500,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Lợi ích dự kiến',
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

  Widget _buildAttachments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_file,
              size: 20,
              color: AppColors.brand500,
            ),
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
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Text(
                            'Ảnh ${index + 1}',
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

  Widget _buildSenderInfo() {
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
                _idea.senderName != null
                    ? Icons.person_outline
                    : Icons.privacy_tip_outlined,
                size: 20,
                color: _idea.senderName != null
                    ? AppColors.brand500
                    : AppColors.themePink500,
              ),
              const SizedBox(width: 8),
              const Text(
                'Người gửi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_idea.senderName != null) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.brand100,
                  child: Text(
                    _idea.senderName![0],
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.brand600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _idea.senderName!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mã NV: ${_idea.senderEmployeeId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                        ),
                      ),
                      Text(
                        _idea.senderDepartment ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.themePink500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock,
                    color: AppColors.themePink500,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Thông tin người gửi được bảo mật',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_idea.currentHandlerName != null) ...[
            const SizedBox(height: 16),
            Divider(color: AppColors.gray100),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  size: 20,
                  color: AppColors.blueLight500,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Đang xử lý bởi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _idea.currentHandlerRole ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueLight700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _idea.currentHandlerName ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProcessTimeline() {
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
                Icons.timeline,
                size: 20,
                color: AppColors.brand500,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tiến trình xử lý',
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
                      'Chưa có cập nhật',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
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
              Container(
                width: 2,
                height: 60,
                color: AppColors.gray200,
              ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.handlerRole} - ${log.handlerName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray600,
                  ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                Icons.star_outline,
                size: 24,
                color: AppColors.warning500,
              ),
              const SizedBox(width: 8),
              const Text(
                'Đánh giá mức độ hài lòng',
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
            'Bạn có hài lòng với cách xử lý góp ý này?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
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
          TextFieldWithMic(
            controller: _feedbackController,
            hintText: 'Nhận xét của bạn (tùy chọn)',
            maxLines: 3,
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
              child: const Text(
                'Gửi đánh giá',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cảm ơn bạn đã đánh giá!'),
        backgroundColor: AppColors.success500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    setState(() {
      // Update local state
    });
  }
}
