import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/idea_box_model.dart';
import '../../services/idea_service.dart';
import '../../widgets/text_field_with_mic.dart';
import '../../widgets/expanded_text_dialog.dart';
import '../../components/loading_infinity.dart';
import '../../utils/toast_utils.dart';
import '../../services/auth_service.dart';

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
  final _expectedBenefitController = TextEditingController();
  final IdeaService _ideaService = IdeaService();

  late IdeaBoxType _selectedBoxType;
  IssueType? _selectedIssueType;
  DifficultyLevel? _selectedDifficulty;
  bool _isSubmitting = false;
  List<File> _attachments = [];
  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedBoxType = widget.initialBoxType;
    if (_selectedBoxType == IdeaBoxType.white) {
      _prefillPersonalInfo();
    } else {
      _clearPersonalInfo();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _positionController.dispose();
    _contentController.dispose();
    _expectedBenefitController.dispose();
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
          title: AppLocalizations.of(context)!.ideaContentTitle,
          hintText: AppLocalizations.of(context)!.ideaContentHint,
        ),
      ),
    );
    setState(() {});
  }

  void _clearPersonalInfo() {
    _nameController.clear();
    _employeeIdController.clear();
    _positionController.clear();
  }

  Future<void> _prefillPersonalInfo() async {
    try {
      // Ưu tiên lấy profile từ backend để có thông tin mới nhất
      final profileResult = await AuthService().getProfile();
      if (mounted && profileResult['success'] == true) {
        final data = profileResult['data'] as Map<String, dynamic>;
        setState(() {
          _nameController.text =
              data['full_name'] ?? data['fullName'] ?? _nameController.text;
          _employeeIdController.text =
              data['employee_code'] ??
              data['employeeCode'] ??
              _employeeIdController.text;
          _positionController.text =
              data['job_title'] ??
              data['position'] ??
              data['role'] ??
              _positionController.text;
        });
        return;
      }

      // Fallback: lấy thông tin đã lưu cục bộ (sau login)
      final localInfo = await AuthService().getUserInfo();
      if (!mounted) return;
      setState(() {
        _nameController.text =
            localInfo['fullName'] ??
            localInfo['full_name'] ??
            _nameController.text;
        _employeeIdController.text =
            localInfo['username'] ?? _employeeIdController.text;
      });
    } catch (_) {
      // Giữ form trống nếu không lấy được
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.appBackgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
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

                            // Lợi ích dự kiến
                            _buildExpectedBenefitField(),
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
              if (_isSubmitting)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const LoadingInfinity(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.createNewIdea,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  l10n.enterIdeaDescription,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ideaCategory,
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
        });
        if (type == IdeaBoxType.white) {
          _prefillPersonalInfo();
        } else {
          _clearPersonalInfo();
        }
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
    final l10n = AppLocalizations.of(context)!;
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
        Text(
          l10n.selectIdeaCategory,
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
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: AppColors.black),
          decoration: const InputDecoration(
            hintText: 'Nhập họ và tên của bạn',
            hintStyle: TextStyle(color: AppColors.gray400),
            filled: true,
            fillColor: AppColors.white,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Vui lòng nhập họ và tên';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Mã nhân viên
        TextFormField(
          controller: _employeeIdController,
          style: const TextStyle(color: AppColors.black),
          decoration: const InputDecoration(
            hintText: 'VD: NV001',
            hintStyle: TextStyle(color: AppColors.gray400),
            filled: true,
            fillColor: AppColors.white,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Vui lòng nhập mã nhân viên';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Chức vụ
        TextFormField(
          controller: _positionController,
          style: const TextStyle(color: AppColors.black),
          decoration: const InputDecoration(
            hintText: 'VD: Công nhân sản xuất',
            hintStyle: TextStyle(color: AppColors.gray400),
            filled: true,
            fillColor: AppColors.white,
          ),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ideaDescription,
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
                Icon(Icons.edit_note, color: AppColors.brand500, size: 24),
              ],
            ),
          ),
        ),
        if (_contentController.text.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Nội dung góp ý phải có ít nhất 10 ký tự',
              style: TextStyle(color: AppColors.gray500, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildExpectedBenefitField() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ideaBenefit,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 12),
        TextFieldWithMic(
          controller: _expectedBenefitController,
          hintText: 'Mô tả lợi ích dự kiến nếu ý tưởng được áp dụng...',
          maxLines: 3,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.addIdeaAttachment,
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
    final l10n = AppLocalizations.of(context)!;
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
        child: Text(
          l10n.submitIdea,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Để ImagePicker tự xử lý quyền trên iOS
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
          ToastUtils.showSuccess(
            AppLocalizations.of(context)!.imageAddedSuccess,
          );
        }
      }
    } on Exception catch (_) {
      if (mounted) {
        // Kiểm tra nếu là lỗi quyền bị từ chối vĩnh viễn
        Permission permission = source == ImageSource.camera
            ? Permission.camera
            : Permission.photos;
        String permissionName = source == ImageSource.camera
            ? 'camera'
            : 'thư viện ảnh';

        final status = await permission.status;
        if (status.isPermanentlyDenied) {
          _showPermissionDialog(permissionName);
        } else {
          String errorMessage = 'Lỗi khi chọn ảnh';
          ToastUtils.showError(errorMessage);
        }
      }
    }
  }

  void _showPermissionDialog(String permissionType) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionDeniedTitle),
        content: Text(l10n.permissionDeniedMessage(permissionType)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _submitIdea() async {
    if (_formKey.currentState!.validate()) {
      final l10n = AppLocalizations.of(context)!;
      if (_selectedIssueType == null) {
        ToastUtils.showWarning(l10n.pleaseSelectIdeaCategory);
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        await _ideaService.createIdea(
          type: _selectedBoxType,
          issueType: _selectedIssueType!,
          title: _contentController.text
              .split('\n')
              .first, // Use first line as title
          content: _contentController.text,
          expectedBenefit: _expectedBenefitController.text.isNotEmpty
              ? _expectedBenefitController.text
              : null,
          attachments: _attachments,
          // Note: Backend doesn't seem to support difficulty level directly in create?
          // It calculates feasibility_score later.
          // We can pass it in description or if backend supports it.
          // For now, we just send basic info.
        );

        if (mounted) {
          final successMessage = _selectedBoxType == IdeaBoxType.white
              ? l10n.ideaSubmitted
              : l10n.ideaSubmitted;

          ToastUtils.showSuccess(successMessage);

          Navigator.pop(context, true); // Return true to refresh list
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError('Lỗi: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}
