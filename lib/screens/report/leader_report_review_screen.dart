import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../utils/toast_utils.dart';
import '../../models/report_model.dart';
import '../../services/incident_service.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_toggle_button.dart';
import '../../widgets/audio_player_widget.dart';

/// Màn hình Leader xem chi tiết và duyệt báo cáo sự cố
class LeaderReportReviewScreen extends StatefulWidget {
  final ReportModel report;

  const LeaderReportReviewScreen({super.key, required this.report});

  @override
  State<LeaderReportReviewScreen> createState() =>
      _LeaderReportReviewScreenState();
}

class _LeaderReportReviewScreenState extends State<LeaderReportReviewScreen> {
  // Loading state
  bool _isLoading = false;

  // Kiểm tra xem báo cáo có ở trạng thái pending không
  bool get _isPending => widget.report.status == ReportStatus.pending;

  // Leader's additional information
  String? _selectedCategory;
  ReportPriority? _selectedPriority;
  String? _selectedComponent;
  String? _selectedProductionLine;
  String? _selectedWorkstation;
  String? _selectedDepartment;
  final TextEditingController _leaderNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with user's selections or existing data if status is "processing"
    _selectedPriority = widget.report.priority;

    // If report is already in processing/completed status, all fields should be filled
    if (widget.report.status == ReportStatus.processing ||
        widget.report.status == ReportStatus.completed) {
      // Pre-fill all required fields with existing data
      _selectedCategory = 'Kỹ thuật'; // TODO: Get from report model
      _selectedComponent = 'Động cơ'; // TODO: Get from report model
      _selectedProductionLine = 'Dây chuyền A'; // TODO: Get from report model
      _selectedWorkstation = 'Lắp ráp'; // TODO: Get from report model
      _selectedDepartment = 'Sản xuất'; // TODO: Get from report model
      _leaderNotesController.text =
          'Đã kiểm tra và xác nhận'; // TODO: Get from report model
    } else {
      // For new reports, try to use category from report if available
      _selectedCategory = widget.report.category?.name;
    }
  }

  @override
  void dispose() {
    _leaderNotesController.dispose();
    super.dispose();
  }

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
        actions: const [
          LanguageToggleIconButton(),
          SizedBox(width: 8),
        ],
        title: Text(
          l10n.incidentDetail,
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: User Information (Read-only)
              _buildSection(l10n.senderInfo, [
                _buildReadOnlyRowField(
                  l10n.reporter,
                  widget.report.title.contains(' - ')
                      ? widget.report.title.split(' - ').last
                      : 'N/A',
                ),
                _buildReadOnlyRowField(
                  l10n.incidentTitle,
                  widget.report.title.split(' - ').first,
                ),
                _buildReadOnlyRowField(
                  l10n.priority,
                  widget.report.priorityLabel,
                ),
                _buildReadOnlyField(
                  l10n.description,
                  widget.report.description ?? l10n.noData,
                ),
                if (widget.report.attachments?.isNotEmpty ?? false)
                  _buildAttachmentsField(),
              ]),

              const SizedBox(height: 24),

              // Section 2: Leader's Additional Information
              // Only show edit form when status is pending
              if (_isPending) ...[
                _buildSection('Xác nhận & Bổ sung thông tin', [
                  _buildDropdownField(
                    'Phân loại vấn đề',
                    _selectedCategory,
                    ['Kỹ thuật', 'An toàn', 'Chất lượng', 'Hành chính'],
                    (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  _buildPriorityDropdown(l10n),
                  _buildDropdownField(
                    l10n.componentName,
                    _selectedComponent,
                    ['Động cơ', 'Băng tải', 'Cảm biến', 'Van điều khiển'],
                    (value) {
                      setState(() => _selectedComponent = value);
                    },
                  ),
                  _buildDropdownField(
                    l10n.productionLine,
                    _selectedProductionLine,
                    ['Dây chuyền A', 'Dây chuyền B', 'Dây chuyền C'],
                    (value) {
                      setState(() => _selectedProductionLine = value);
                    },
                  ),
                  _buildDropdownField(
                    'Công đoạn',
                    _selectedWorkstation,
                    ['Đúc', 'Dập', 'Lắp ráp', 'Kiểm tra'],
                    (value) {
                      setState(() => _selectedWorkstation = value);
                    },
                  ),
                  _buildDropdownField(
                    'Bộ phận phát hiện',
                    _selectedDepartment,
                    ['QC', 'Sản xuất', 'Bảo trì', 'An toàn'],
                    (value) {
                      setState(() => _selectedDepartment = value);
                    },
                  ),
                  _buildTextAreaField(
                    'Ghi chú của Leader',
                    _leaderNotesController,
                    'Nhập ghi chú (tùy chọn)',
                  ),
                ]),
              ] else ...[
                // Read-only section cho trạng thái đang xử lý hoặc hoàn thành
                _buildSection('Thông tin xử lý', [
                  _buildReadOnlyRowField(
                    'Trạng thái',
                    widget.report.statusLabel,
                  ),
                  if (_selectedCategory != null)
                    _buildReadOnlyRowField(l10n.category, _selectedCategory!),
                  if (_selectedComponent != null)
                    _buildReadOnlyRowField(
                      l10n.componentName,
                      _selectedComponent!,
                    ),
                  if (_selectedProductionLine != null)
                    _buildReadOnlyRowField(
                      l10n.productionLine,
                      _selectedProductionLine!,
                    ),
                  if (_selectedWorkstation != null)
                    _buildReadOnlyRowField(
                      l10n.workstation,
                      _selectedWorkstation!,
                    ),
                  if (_selectedDepartment != null)
                    _buildReadOnlyRowField(
                      l10n.detectionDepartment,
                      _selectedDepartment!,
                    ),
                  if (_leaderNotesController.text.isNotEmpty)
                    _buildReadOnlyField(
                      l10n.leaderNotes,
                      _leaderNotesController.text,
                    ),
                ]),
              ],

              const SizedBox(height: 32),

              // Action Buttons - Chỉ hiển thị khi trạng thái là pending
              if (_isPending) _buildActionButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withOpacity(0.3),
            blurRadius: 8,
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReadOnlyRowField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: AppColors.gray900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 14, color: AppColors.gray900)),
        ],
      ),
    );
  }

  Widget _buildAttachmentsField() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.attachments,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 8),
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
                children: widget.report.attachments!.map((attachment) {
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
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    final GlobalKey dropdownKey = GlobalKey();
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
              Text(' *', style: TextStyle(color: AppColors.error500)),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            key: dropdownKey,
            onTap: () async {
              final RenderBox? renderBox =
                  dropdownKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox == null) return;

              final overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;

              final buttonPosition = renderBox.localToGlobal(
                Offset.zero,
                ancestor: overlay,
              );
              final buttonSize = renderBox.size;

              final position = RelativeRect.fromRect(
                Rect.fromLTWH(
                  buttonPosition.dx + buttonSize.width, // Align right edge
                  buttonPosition.dy + buttonSize.height,
                  0, // Width will be auto
                  0,
                ),
                Offset.zero & overlay.size,
              );

              final result = await showMenu<String>(
                context: context,
                position: position,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                items: items
                    .map(
                      (item) => PopupMenuItem<String>(
                        value: item,
                        height: 40,
                        child: Text(item, style: TextStyle(fontSize: 14)),
                      ),
                    )
                    .toList(),
              );

              if (result != null) onChanged(result);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value ?? '${l10n.select} $label',
                      style: TextStyle(
                        fontSize: 14,
                        color: value != null
                            ? AppColors.gray900
                            : AppColors.gray400,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.gray600,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDropdown(AppLocalizations l10n) {
    final GlobalKey dropdownKey = GlobalKey();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.confirmPriority,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
              Text(' *', style: TextStyle(color: AppColors.error500)),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            key: dropdownKey,
            onTap: () async {
              final RenderBox? renderBox =
                  dropdownKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox == null) return;

              final overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;

              final buttonPosition = renderBox.localToGlobal(
                Offset.zero,
                ancestor: overlay,
              );
              final buttonSize = renderBox.size;

              final position = RelativeRect.fromRect(
                Rect.fromLTWH(
                  buttonPosition.dx + buttonSize.width, // Align right edge
                  buttonPosition.dy + buttonSize.height,
                  0, // Width will be auto
                  0,
                ),
                Offset.zero & overlay.size,
              );

              final result = await showMenu<ReportPriority>(
                context: context,
                position: position,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                items: ReportPriority.values.map((priority) {
                  String displayName;
                  switch (priority) {
                    case ReportPriority.low:
                      displayName = l10n.low;
                      break;
                    case ReportPriority.medium:
                      displayName = l10n.medium;
                      break;
                    case ReportPriority.high:
                      displayName = l10n.high;
                      break;
                    case ReportPriority.urgent:
                      displayName = l10n.critical;
                      break;
                  }
                  return PopupMenuItem<ReportPriority>(
                    value: priority,
                    height: 40,
                    child: Text(displayName, style: TextStyle(fontSize: 14)),
                  );
                }).toList(),
              );

              if (result != null) {
                setState(() => _selectedPriority = result);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedPriority != null
                          ? () {
                              switch (_selectedPriority!) {
                                case ReportPriority.low:
                                  return l10n.low;
                                case ReportPriority.medium:
                                  return l10n.medium;
                                case ReportPriority.high:
                                  return l10n.high;
                                case ReportPriority.urgent:
                                  return l10n.critical;
                              }
                            }()
                          : l10n.selectPriority,
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedPriority != null
                            ? AppColors.gray900
                            : AppColors.gray400,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.gray600,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.gray50,
              hintText: hint,
              hintStyle: TextStyle(fontSize: 14, color: AppColors.gray400),
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.gray300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.brand500, width: 2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.gray300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Approve Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _validateAndApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error500, // Changed to red
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'DUYỆT & GỬI LÊN ADMIN',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Return to User Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _showReturnDialog,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.orange500, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'TRẢ LẠI USER',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.orange500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Cancel Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _showCancelDialog,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.error500, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'HỦY BỎ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.error500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _validateAndApprove() {
    final l10n = AppLocalizations.of(context)!;
    // Validate required fields
    if (_selectedCategory == null ||
        _selectedPriority == null ||
        _selectedComponent == null ||
        _selectedProductionLine == null ||
        _selectedWorkstation == null ||
        _selectedDepartment == null) {
      ToastUtils.showError(l10n.pleaseFillRequiredFields);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmApproval),
        content: Text(l10n.confirmApproveMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _performApprove();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success500,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _performApprove() async {
    setState(() => _isLoading = true);

    try {
      final result = await IncidentService.approveIncident(
        incidentId: widget.report.id,
        priority: _selectedPriority!.name,
        category: _selectedCategory,
        component: _selectedComponent,
        productionLine: _selectedProductionLine,
        workstation: _selectedWorkstation,
        department: _selectedDepartment,
        leaderNotes: _leaderNotesController.text.isNotEmpty
            ? _leaderNotesController.text
            : null,
      );

      setState(() => _isLoading = false);

      final l10n = AppLocalizations.of(context)!;
      if (result['success'] == true || result['data'] != null) {
        if (mounted) {
          Navigator.pop(context, true); // Return true to refresh list
          ToastUtils.showSuccess(l10n.approvedAndSentToAdmin);
        }
      } else {
        if (mounted) {
          ToastUtils.showError(result['message'] ?? l10n.cannotApproveReport);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ToastUtils.showError('${l10n.error}: $e');
      }
    }
  }

  void _showReturnDialog() {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.returnToUser),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.returnReasonHint,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ToastUtils.showWarning(l10n.pleaseEnterReturnReason);
                return;
              }
              Navigator.pop(context); // Close dialog
              await _performReturn(reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange500,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _performReturn(String reason) async {
    setState(() => _isLoading = true);

    try {
      final result = await IncidentService.returnToUser(
        incidentId: widget.report.id,
        reason: reason,
      );

      setState(() => _isLoading = false);

      final l10n = AppLocalizations.of(context)!;
      if (result['success'] == true || result['data'] != null) {
        if (mounted) {
          Navigator.pop(context, true); // Return true to refresh list
          ToastUtils.showWarning(l10n.returnedToUser);
        }
      } else {
        if (mounted) {
          ToastUtils.showError(result['message'] ?? l10n.cannotReturnReport);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ToastUtils.showError('${l10n.error}: $e');
      }
    }
  }

  void _showCancelDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelReport),
        content: Text(l10n.confirmCancelMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _performCancel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error500,
            ),
            child: Text(l10n.confirmCancel),
          ),
        ],
      ),
    );
  }

  Future<void> _performCancel() async {
    setState(() => _isLoading = true);

    try {
      final l10n = AppLocalizations.of(context)!;
      final result = await IncidentService.cancelIncident(
        incidentId: widget.report.id,
        reason: l10n.cancelledByLeader,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true || result['data'] != null) {
        if (mounted) {
          Navigator.pop(context, true); // Return true to refresh list
          ToastUtils.showError(l10n.reportCancelled);
        }
      } else {
        if (mounted) {
          ToastUtils.showError(result['message'] ?? l10n.cannotCancelReport);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ToastUtils.showError('${l10n.error}: $e');
      }
    }
  }
}
