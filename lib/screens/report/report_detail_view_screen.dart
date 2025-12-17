import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../config/app_colors.dart';
import '../../utils/toast_utils.dart';
import '../../models/report_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_toggle_button.dart';
import '../../services/api_service.dart';
import '../../services/incident_service.dart';
import '../../services/auth_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  List<Map<String, dynamic>> _departments = [];
  String? _selectedDepartmentId;
  bool _isLoadingDepartments = false;
  bool _isAssigning = false;
  String? _userRole;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadDepartments();
    _loadComments();
  }

  /// Apply RAG suggestion - auto fill department dropdown for pending incidents
  /// Only applies when:
  /// - Admin has enabled RAG (rag_suggestion exists)
  /// - Incident is still pending (needs leader review)
  void _applyRagSuggestion() {
    final suggestion = widget.report.ragSuggestion;
    if (suggestion == null) {
      print('🤖 [RAG] No AI suggestion (RAG disabled or no match found)');
      return;
    }

    // Only auto-fill for pending incidents
    if (!_canAssignDepartment || _departments.isEmpty) {
      print('🤖 [RAG] Cannot assign department, skipping auto-fill');
      return;
    }

    print(
      '🤖 [RAG] AI Suggestion: ${suggestion.departmentName} (${suggestion.confidencePercent}%)',
    );

    final matchingDept = _departments.firstWhere(
      (d) => d['id'].toString() == suggestion.departmentId,
      orElse: () => {},
    );

    if (matchingDept.isNotEmpty) {
      setState(() {
        _selectedDepartmentId = suggestion.departmentId;
      });
      print('🤖 [RAG] Pre-filled department: ${matchingDept['name']}');
    }
  }

  Future<void> _loadUserRole() async {
    final userInfo = await AuthService().getUserInfo();
    if (mounted) {
      setState(() {
        _userRole = userInfo['role'];
      });
      print('🔍 [DEBUG] User role: $_userRole');
      print('🔍 [DEBUG] Report status: ${widget.report.status}');
      print('🔍 [DEBUG] Can assign department: $_canAssignDepartment');
    }
  }

  Future<void> _loadDepartments() async {
    setState(() => _isLoadingDepartments = true);
    try {
      print('🔍 [DEBUG] Loading departments...');
      final departments = await IncidentService.getDepartments();
      print('🔍 [DEBUG] Departments loaded: ${departments.length} items');
      if (departments.isNotEmpty) {
        print('🔍 [DEBUG] First department: ${departments.first}');
      }
      if (mounted) {
        setState(() {
          _departments = departments;
          _isLoadingDepartments = false;
        });
        // Apply RAG suggestion after departments loaded
        _applyRagSuggestion();
      }
    } catch (e) {
      print('❌ [DEBUG] Error loading departments: $e');
      if (mounted) {
        setState(() => _isLoadingDepartments = false);
      }
    }
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      print('💬 [DEBUG] Loading comments for incident: ${widget.report.id}');
      final comments = await IncidentService.getIncidentComments(
        incidentId: widget.report.id,
      );
      print('💬 [DEBUG] Comments loaded: ${comments.length} items');
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      print('❌ [DEBUG] Error loading comments: $e');
      if (mounted) {
        setState(() => _isLoadingComments = false);
      }
    }
  }

  bool get _canAssignDepartment {
    // Only leader role can assign, only pending incidents can be assigned
    return _userRole == 'leader' &&
        widget.report.status == ReportStatus.pending;
  }

  Future<void> _assignDepartment() async {
    if (_selectedDepartmentId == null) {
      ToastUtils.showWarning('Vui lòng chọn phòng ban');
      return;
    }

    setState(() => _isAssigning = true);
    try {
      final result = await IncidentService.assignDepartment(
        incidentId: widget.report.id,
        departmentId: _selectedDepartmentId!,
      );

      if (result['success'] == true) {
        ToastUtils.showSuccess('Đã điều phối thành công');
        if (mounted) {
          Navigator.pop(context, true); // Return true to refresh list
        }
      } else {
        ToastUtils.showError(result['message'] ?? 'Điều phối thất bại');
      }
    } catch (e) {
      ToastUtils.showError('Lỗi: $e');
    } finally {
      if (mounted) {
        setState(() => _isAssigning = false);
      }
    }
  }

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

  ReportModel get report => widget.report;

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
        actions: const [LanguageToggleIconButton(), SizedBox(width: 8)],
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
                  FutureBuilder<String>(
                    future: ApiService.getBaseUrl(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final baseUrl = snapshot.data!;
                      return Column(
                        children: report.attachments!.map((attachment) {
                          final fullUrl = attachment.getFullUrl(baseUrl);

                          if (attachment.isImage) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.gray200),
                                image: DecorationImage(
                                  image: NetworkImage(fullUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else if (attachment.isAudio) {
                            return AudioPlayerWidget(url: fullUrl);
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attachment,
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
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Comments/Feedback Section (show manager's responses)
            if (_comments.isNotEmpty) ...[
              _buildDetailCard(
                title: l10n.comments,
                children: [
                  ..._comments.map((comment) {
                    final createdAt = comment['created_at'] != null
                        ? DateTime.parse(comment['created_at'])
                        : null;
                    final authorName = comment['author_name'] ?? 'Quản lý';
                    final content = comment['content'] ?? comment['notes'] ?? '';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.brand50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.brand200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: AppColors.brand500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                authorName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brand700,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              if (createdAt != null)
                                Text(
                                  '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray500,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content,
                            style: TextStyle(
                              color: AppColors.gray700,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Loading comments indicator
            if (_isLoadingComments) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gray200.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brand500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Đang tải phản hồi...',
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
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

            // Department Assignment Card (Leader only, pending status only)
            if (_canAssignDepartment) ...[
              _buildDetailCard(
                title: l10n.responsibleDepartment,
                children: [
                  // AI Suggestion Banner
                  _buildAiSuggestionBanner(),
                  if (_isLoadingDepartments)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    // Department Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gray300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(
                            l10n.selectDepartment,
                            style: TextStyle(color: AppColors.gray500),
                          ),
                          value: _selectedDepartmentId,
                          items: _departments.map((dept) {
                            return DropdownMenuItem<String>(
                              value: dept['id'].toString(),
                              child: Text(dept['name'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartmentId = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Assign Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isAssigning ? null : _assignDepartment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand500,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isAssigning
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Điều phối',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
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

  /// Build AI suggestion banner widget
  /// Only shows when RAG is enabled and has suggestion for pending incidents
  Widget _buildAiSuggestionBanner() {
    final suggestion = widget.report.ragSuggestion;
    // Only show banner for pending incidents with RAG suggestion
    if (suggestion == null || !_canAssignDepartment) return const SizedBox.shrink();

    // Check if user has changed department from suggestion
    final bool isUsingAiSuggestion =
        _selectedDepartmentId == suggestion.departmentId;
    final bool userChangedDepartment =
        _selectedDepartmentId != null && !isUsingAiSuggestion;

    // Use blue theme for suggestions
    final Color bannerColor = AppColors.blueLight500;
    final Color textColor = AppColors.blueLight700;
    final Color iconColor = AppColors.blueLight600;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bannerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'AI gợi ý: ${suggestion.departmentName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bannerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${suggestion.confidencePercent}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Status row based on user action
          if (userChangedDepartment)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Bạn đã thay đổi phòng ban',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _applyRagSuggestion,
                  style: TextButton.styleFrom(
                    foregroundColor: iconColor,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Dùng lại gợi ý', style: TextStyle(fontSize: 12)),
                ),
              ],
            )
          else
            Text(
              'Đề xuất của AI (bạn có thể thay đổi)',
              style: TextStyle(fontSize: 12, color: iconColor),
            ),
        ],
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

class AudioPlayerWidget extends StatefulWidget {
  final String url;

  const AudioPlayerWidget({super.key, required this.url});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      setState(() => _isLoading = true);
      try {
        await _audioPlayer.play(UrlSource(widget.url));
      } catch (e) {
        // Handle error
        print('Error playing audio: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.brand500,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                  onPressed: _isLoading ? null : _togglePlay,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                        trackHeight: 4,
                        activeTrackColor: AppColors.brand500,
                        inactiveTrackColor: AppColors.gray300,
                        thumbColor: AppColors.brand500,
                      ),
                      child: Slider(
                        min: 0,
                        max: _duration.inSeconds.toDouble(),
                        value: _position.inSeconds.toDouble().clamp(
                          0,
                          _duration.inSeconds.toDouble(),
                        ),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await _audioPlayer.seek(position);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              color: AppColors.gray600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              color: AppColors.gray600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
