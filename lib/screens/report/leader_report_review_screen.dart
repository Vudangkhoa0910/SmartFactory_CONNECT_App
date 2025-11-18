import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/report_model.dart';

/// Màn hình Leader xem chi tiết và duyệt báo cáo sự cố
class LeaderReportReviewScreen extends StatefulWidget {
  final ReportModel report;

  const LeaderReportReviewScreen({super.key, required this.report});

  @override
  State<LeaderReportReviewScreen> createState() =>
      _LeaderReportReviewScreenState();
}

class _LeaderReportReviewScreenState extends State<LeaderReportReviewScreen> {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.gray800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiết sự cố ${widget.report.id}',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: User Information (Read-only)
              _buildSection('Thông tin từ người gửi', [
                _buildReadOnlyRowField(
                  'Người gửi',
                  widget.report.title.contains(' - ')
                      ? widget.report.title.split(' - ').last
                      : 'N/A',
                ),
                _buildReadOnlyRowField(
                  'Tiêu đề sự cố',
                  widget.report.title.split(' - ').first,
                ),
                _buildReadOnlyRowField(
                  'Mức độ ưu tiên',
                  widget.report.priorityLabel,
                ),
                _buildReadOnlyField(
                  'Mô tả chi tiết',
                  widget.report.description ?? 'Không có mô tả',
                ),
                if (widget.report.attachments?.isNotEmpty ?? false)
                  _buildAttachmentsField(),
              ]),

              const SizedBox(height: 24),

              // Section 2: Leader's Additional Information
              _buildSection('Xác nhận & Bổ sung thông tin', [
                _buildDropdownField(
                  'Phân loại vấn đề',
                  _selectedCategory,
                  ['Kỹ thuật', 'An toàn', 'Chất lượng', 'Hành chính'],
                  (value) {
                    setState(() => _selectedCategory = value);
                  },
                ),
                _buildPriorityDropdown(),
                _buildDropdownField(
                  'Tên linh kiện',
                  _selectedComponent,
                  ['Động cơ', 'Băng tải', 'Cảm biến', 'Van điều khiển'],
                  (value) {
                    setState(() => _selectedComponent = value);
                  },
                ),
                _buildDropdownField(
                  'Tên dây chuyền',
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

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hình ảnh/Video đính kèm',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              // TODO: View attachments
            },
            icon: Icon(Icons.attachment, color: AppColors.brand500, size: 18),
            label: Text(
              'Xem ${widget.report.attachments?.length} file đính kèm',
              style: TextStyle(color: AppColors.brand500, fontSize: 14),
            ),
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
                      value ?? 'Chọn $label',
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

  Widget _buildPriorityDropdown() {
    final GlobalKey dropdownKey = GlobalKey();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Xác nhận mức độ ưu tiên',
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
                      displayName = 'Thấp';
                      break;
                    case ReportPriority.medium:
                      displayName = 'Trung bình';
                      break;
                    case ReportPriority.high:
                      displayName = 'Cao';
                      break;
                    case ReportPriority.urgent:
                      displayName = 'Khẩn cấp';
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
                                  return 'Thấp';
                                case ReportPriority.medium:
                                  return 'Trung bình';
                                case ReportPriority.high:
                                  return 'Cao';
                                case ReportPriority.urgent:
                                  return 'Khẩn cấp';
                              }
                            }()
                          : 'Chọn mức độ ưu tiên',
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
    // Validate required fields
    if (_selectedCategory == null ||
        _selectedPriority == null ||
        _selectedComponent == null ||
        _selectedProductionLine == null ||
        _selectedWorkstation == null ||
        _selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ các trường bắt buộc (*)'),
          backgroundColor: AppColors.error500,
        ),
      );
      return;
    }

    // TODO: Submit approval to API
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận duyệt'),
        content: Text('Bạn có chắc muốn duyệt báo cáo này và gửi lên Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã duyệt và gửi báo cáo lên Admin'),
                  backgroundColor: AppColors.success500,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success500,
            ),
            child: Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Trả lại User'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Lý do trả lại (VD: Cần chụp ảnh rõ hơn)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng nhập lý do trả lại')),
                );
                return;
              }
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã trả lại báo cáo cho User'),
                  backgroundColor: AppColors.orange500,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange500,
            ),
            child: Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hủy báo cáo'),
        content: Text(
          'Bạn có chắc muốn hủy báo cáo này? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã hủy báo cáo'),
                  backgroundColor: AppColors.error500,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error500,
            ),
            child: Text('Xác nhận hủy'),
          ),
        ],
      ),
    );
  }
}
