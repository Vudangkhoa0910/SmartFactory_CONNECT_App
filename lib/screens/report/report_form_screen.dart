import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedPriority;
  String? _selectedCategory;

  final List<String> _priorities = ['Thấp', 'Trung bình', 'Cao', 'Khẩn cấp'];

  final List<String> _categories = [
    'Kỹ thuật',
    'An toàn',
    'Chất lượng',
    'Quy trình',
    'Nhân sự',
    'Khác',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Thấp':
        return AppColors.success500;
      case 'Trung bình':
        return AppColors.blueLight500;
      case 'Cao':
        return AppColors.orange500;
      case 'Khẩn cấp':
        return AppColors.error500;
      default:
        return AppColors.gray400;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Báo cáo sự cố / Yêu cầu hỗ trợ',
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tiêu đề sự cố
            _buildSectionTitle('Tiêu đề sự cố', isRequired: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Nhập tiêu đề sự cố',
                hintStyle: TextStyle(color: AppColors.gray400),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.brand500, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tiêu đề sự cố';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Vị trí / Thiết bị
            _buildSectionTitle('Vị trí / Thiết bị', isRequired: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Nhập vị trí hoặc tên thiết bị',
                hintStyle: TextStyle(color: AppColors.gray400),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.brand500, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập vị trí hoặc thiết bị';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Mức độ ưu tiên
            _buildSectionTitle('Mức độ ưu tiên', isRequired: true),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _priorities.map((priority) {
                final isSelected = _selectedPriority == priority;
                return FilterChip(
                  label: Text(priority),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? priority : null;
                    });
                  },
                  backgroundColor: AppColors.white,
                  selectedColor: _getPriorityColor(priority).withOpacity(0.1),
                  checkmarkColor: _getPriorityColor(priority),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? _getPriorityColor(priority)
                        : AppColors.gray700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? _getPriorityColor(priority)
                        : AppColors.gray200,
                    width: isSelected ? 2 : 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Phân loại vấn đề
            _buildSectionTitle('Phân loại vấn đề'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                hintText: 'Chọn loại vấn đề',
                hintStyle: TextStyle(color: AppColors.gray400),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.brand500, width: 2),
                ),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Mô tả chi tiết
            _buildSectionTitle('Mô tả chi tiết'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Mô tả chi tiết về sự cố...',
                hintStyle: TextStyle(color: AppColors.gray400),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.brand500, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Đính kèm bằng chứng
            _buildSectionTitle('Đính kèm bằng chứng'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAttachmentButton(
                    icon: Icons.camera_alt,
                    label: 'Chụp ảnh',
                    onTap: () {
                      // TODO: Implement camera
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAttachmentButton(
                    icon: Icons.photo_library,
                    label: 'Tải ảnh/Video',
                    onTap: () {
                      // TODO: Implement gallery
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAttachmentButton(
              icon: Icons.mic,
              label: 'Ghi âm',
              onTap: () {
                // TODO: Implement audio recording
              },
            ),
            const SizedBox(height: 32),

            // Nút gửi báo cáo
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_selectedPriority == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Vui lòng chọn mức độ ưu tiên'),
                        backgroundColor: AppColors.error500,
                      ),
                    );
                    return;
                  }
                  // TODO: Submit form
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã gửi báo cáo thành công!'),
                      backgroundColor: AppColors.success500,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand500,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'GỬI BÁO CÁO NGAY',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              color: AppColors.error500,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.brand500, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.gray700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
