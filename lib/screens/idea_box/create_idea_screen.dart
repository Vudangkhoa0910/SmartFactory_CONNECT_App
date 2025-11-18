import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../models/idea_box_model.dart';
import '../../widgets/text_field_with_mic.dart';
import '../../widgets/expanded_text_dialog.dart';

/// Màn hình tạo góp ý mới
/// Hỗ trợ cả Hòm thư trắng (công khai) và Hòm thư hồng (ẩn danh)
class CreateIdeaScreen extends StatefulWidget {
  final IdeaBoxType initialBoxType;

  const CreateIdeaScreen({super.key, required this.initialBoxType});

  @override
  State<CreateIdeaScreen> createState() => _CreateIdeaScreenState();
}

class _CreateIdeaScreenState extends State<CreateIdeaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _positionController = TextEditingController();
  final _contentController = TextEditingController();

  late IdeaBoxType _selectedBoxType;
  IssueType? _selectedIssueType;
  DifficultyLevel? _selectedDifficulty;
  bool _isAnonymous = false;
  List<File> _attachments = [];
  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedBoxType = widget.initialBoxType;
    _isAnonymous = _selectedBoxType == IdeaBoxType.pink;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _positionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _openExpandedContentDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ExpandedTextDialog(
          controller: _contentController,
          title: 'Ý kiến / Nội dung góp ý',
          hintText: 'Nhập ý kiến hoặc nội dung góp ý của bạn...',
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.appBackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBoxTypeSelector(),
                        const SizedBox(height: 24),
                        _buildIssueTypeSelector(),
                        const SizedBox(height: 24),

                        // Thông tin cá nhân
                        _buildPersonalInfoSection(),
                        const SizedBox(height: 24),

                        // Ngày gửi
                        _buildDateField(),
                        const SizedBox(height: 20),

                        // Nội dung góp ý
                        _buildContentField(),
                        const SizedBox(height: 20),

                        if (_selectedBoxType == IdeaBoxType.white) ...[
                          _buildDifficultySelector(),
                          const SizedBox(height: 20),
                        ],
                        _buildAttachmentSection(),
                        const SizedBox(height: 24),
                        if (_selectedBoxType == IdeaBoxType.pink)
                          _buildAnonymousNote(),
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                        const SizedBox(height: 20),
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
                const Text(
                  'Gửi góp ý mới',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  'Chia sẻ ý tưởng của bạn',
                  style: TextStyle(fontSize: 14, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại hòm thư',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBoxTypeCard(
                type: IdeaBoxType.white,
                icon: Icons.inbox_outlined,
                title: 'Hòm trắng',
                subtitle: 'Ai cũng xem được',
                color: AppColors.brand500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBoxTypeCard(
                type: IdeaBoxType.pink,
                icon: Icons.favorite_border,
                title: 'Hòm hồng',
                subtitle: 'Chỉ bạn xem được',
                color: AppColors.themePink500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBoxTypeCard({
    required IdeaBoxType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedBoxType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBoxType = type;
          _isAnonymous = type == IdeaBoxType.pink;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.gray200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : AppColors.gray50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? color : AppColors.gray400,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueTypeSelector() {
    // Lọc loại vấn đề theo loại hòm thư
    final issueTypes = _selectedBoxType == IdeaBoxType.white
        ? [
            IssueType.quality,
            IssueType.safety,
            IssueType.performance,
            IssueType.energySaving,
            IssueType.process,
            IssueType.other,
          ]
        : [
            IssueType.workEnvironment,
            IssueType.welfare,
            IssueType.pressure,
            IssueType.psychologicalSafety,
            IssueType.fairness,
            IssueType.other,
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại vấn đề *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: issueTypes.map((type) {
            final isSelected = _selectedIssueType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIssueType = type;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.brand500 : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.brand500 : AppColors.gray200,
                  ),
                ),
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.gray700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    final isRequired = _selectedBoxType == IdeaBoxType.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Thông tin cá nhân',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(width: 8),
            if (!isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.themePink100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Tùy chọn',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.themePink500,
                  ),
                ),
              ),
          ],
        ),
        if (!isRequired) ...[
          const SizedBox(height: 8),
          Text(
            'Bạn có thể bỏ qua nếu muốn gửi hoàn toàn ẩn danh',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 12),

        // Họ và tên
        TextFieldWithMic(
          controller: _nameController,
          hintText: 'Nhập họ và tên của bạn',
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Vui lòng nhập họ và tên';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Mã nhân viên
        TextFieldWithMic(
          controller: _employeeIdController,
          hintText: 'VD: NV001',
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Vui lòng nhập mã nhân viên';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Chức vụ
        TextFieldWithMic(
          controller: _positionController,
          hintText: 'VD: Công nhân sản xuất',
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Vui lòng nhập chức vụ';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày gửi *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.brand500,
                      onPrimary: AppColors.white,
                      onSurface: AppColors.gray900,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.gray400, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.gray400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ý kiến / Nội dung góp ý *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _openExpandedContentDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            constraints: const BoxConstraints(minHeight: 120),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _contentController.text.isEmpty
                        ? 'Nhấn để nhập ý kiến hoặc nội dung góp ý...'
                        : _contentController.text,
                    style: TextStyle(
                      color: _contentController.text.isEmpty
                          ? AppColors.gray400
                          : AppColors.black,
                      fontSize: 14,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_note,
                  color: AppColors.brand500,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_contentController.text.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Nội dung góp ý phải có ít nhất 10 ký tự',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mức độ khó (tùy chọn)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: DifficultyLevel.values.map((level) {
            final isSelected = _selectedDifficulty == level;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDifficulty = level;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.warning100 : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.warning500
                          : AppColors.gray200,
                    ),
                  ),
                  child: Text(
                    level.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.warning700
                          : AppColors.gray600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đính kèm ảnh/video (tùy chọn)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 12),
        if (_attachments.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _attachments.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_attachments[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _attachments.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error500,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: _buildAttachmentButton(
                icon: Icons.photo_camera,
                label: 'Chụp ảnh',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAttachmentButton(
                icon: Icons.photo_library,
                label: 'Thư viện',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.brand500),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.themePink500.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.themePink500.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: AppColors.themePink500,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Thông tin cá nhân là tùy chọn. Nếu bỏ trống, góp ý sẽ hoàn toàn ẩn danh.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitIdea,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand500,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Gửi góp ý',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _attachments.add(File(image.path));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã thêm ảnh thành công'),
              backgroundColor: AppColors.success500,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        String errorMessage = 'Lỗi khi chọn ảnh';

        // Xử lý các lỗi cụ thể
        if (e.toString().contains('camera_access_denied')) {
          errorMessage = 'Vui lòng cấp quyền truy cập camera trong Cài đặt';
        } else if (e.toString().contains('photo_access_denied')) {
          errorMessage =
              'Vui lòng cấp quyền truy cập thư viện ảnh trong Cài đặt';
        } else if (e.toString().contains('No implementation found')) {
          errorMessage =
              'Camera không khả dụng trên Simulator. Vui lòng thử trên thiết bị thật';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error500,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: AppColors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _submitIdea() {
    if (_formKey.currentState!.validate()) {
      if (_selectedIssueType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn loại vấn đề'),
            backgroundColor: AppColors.warning500,
          ),
        );
        return;
      }

      // TODO: Gọi API để lưu góp ý

      final successMessage = _selectedBoxType == IdeaBoxType.white
          ? 'Đã ghi nhận ý kiến của bạn'
          : 'Góp ý của bạn đã được gửi ẩn danh';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: AppColors.success500,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }
}
