import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../models/user_profile_model.dart';
import '../../../providers/user_provider.dart';
import 'personal_info_edit_field_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final UserProfile user;

  const PersonalInfoScreen({super.key, required this.user});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isEditing = false;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  UserRole _currentRole = UserRole.worker;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.user.role;
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _emailController = TextEditingController(text: widget.user.email);
    _addressController = TextEditingController(text: widget.user.address);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu thông tin'),
        backgroundColor: AppColors.success500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.gray900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thông tin cá nhân',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ảnh hồ sơ',
                    style: TextStyle(fontSize: 14, color: AppColors.gray600),
                  ),
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.brand50,
                    child: Text(
                      widget.user.fullName.isNotEmpty
                          ? widget.user.fullName[0].toUpperCase()
                          : 'A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brand500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection('Thông tin cá nhân', [
              _buildInfoField('Họ và tên', widget.user.fullName, true),
              _buildInfoField('Mã nhân viên', widget.user.employeeId, false),
              _buildGenderDropdown(),
              _buildInfoField(
                'Ngày sinh',
                '${widget.user.dateOfBirth.day}/${widget.user.dateOfBirth.month}/${widget.user.dateOfBirth.year}',
                false,
              ),
              _isEditing
                  ? _buildEditField('Số điện thoại', _phoneController)
                  : _buildInfoField(
                      'Số điện thoại',
                      widget.user.phoneNumber,
                      true,
                    ),
              _isEditing
                  ? _buildEditField('Email', _emailController)
                  : _buildInfoField('Email', widget.user.email, true),
              _isEditing
                  ? _buildEditField('Địa chỉ', _addressController, maxLines: 3)
                  : _buildInfoField(
                      'Địa chỉ',
                      widget.user.address ?? 'Chưa cập nhật',
                      true,
                    ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Thông tin công việc', [
              _buildRoleDropdown(),
              _buildInfoField('Bộ phận', widget.user.department, false),
              _buildInfoField(
                'Ngày vào công ty',
                '${widget.user.joinDate.day}/${widget.user.joinDate.month}/${widget.user.joinDate.year}',
                false,
              ),
              _buildInfoField(
                'Ca làm việc',
                widget.user.shift.displayName,
                false,
              ),
              _buildInfoField(
                'Tình trạng',
                widget.user.workStatus.displayName,
                false,
                valueColor: _getWorkStatusColor(widget.user.workStatus),
              ),
            ]),
            if (_isEditing) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'LƯU THAY ĐỔI',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    String value,
    bool canEdit, {
    Color? valueColor,
  }) {
    // Determine edit parameters based on label
    String getEditTitle() {
      if (label == 'Họ và tên') return 'Chỉnh sửa họ tên';
      if (label == 'Số điện thoại') return 'Chỉnh sửa số điện thoại';
      if (label == 'Email') return 'Chỉnh sửa email';
      if (label == 'Địa chỉ') return 'Chỉnh sửa địa chỉ';
      return 'Chỉnh sửa';
    }

    IconData getIcon() {
      if (label == 'Họ và tên') return Icons.person_outline;
      if (label == 'Số điện thoại') return Icons.phone_outlined;
      if (label == 'Email') return Icons.email_outlined;
      if (label == 'Địa chỉ') return Icons.location_on_outlined;
      return Icons.edit_outlined;
    }

    int getMaxLines() {
      if (label == 'Địa chỉ') return 3;
      return 1;
    }

    void updateValue(String newValue) {
      if (label == 'Họ và tên') {
        // TODO: Update fullName in user model
      } else if (label == 'Số điện thoại') {
        _phoneController.text = newValue;
      } else if (label == 'Email') {
        _emailController.text = newValue;
      } else if (label == 'Địa chỉ') {
        _addressController.text = newValue;
      }
    }

    return GestureDetector(
      onTap: canEdit && !widget.user.canEditEmployeeInfo
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalInfoEditFieldScreen(
                    title: getEditTitle(),
                    label: label,
                    initialValue: value,
                    icon: getIcon(),
                    maxLines: getMaxLines(),
                    onSave: (newValue) {
                      setState(() {
                        updateValue(newValue);
                      });
                    },
                  ),
                ),
              );
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: AppColors.gray600),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? AppColors.gray900,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  if (canEdit && !widget.user.canEditEmployeeInfo) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.gray400,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    final GlobalKey _genderKey = GlobalKey();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Giới tính',
              style: TextStyle(fontSize: 14, color: AppColors.gray600),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              key: _genderKey,
              onTap: () {
                final RenderBox renderBox =
                    _genderKey.currentContext!.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);
                final size = renderBox.size;

                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;

                showMenu<Gender>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    position.dx + size.width - 100,
                    position.dy + size.height,
                    overlay.size.width - (position.dx + size.width),
                    overlay.size.height - (position.dy + size.height),
                  ),
                  items: [Gender.male, Gender.female].map((Gender gender) {
                    return PopupMenuItem<Gender>(
                      value: gender,
                      height: 36,
                      child: Text(
                        gender.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray900,
                        ),
                      ),
                    );
                  }).toList(),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ).then((Gender? selectedGender) {
                  if (selectedGender != null) {
                    setState(() {
                      // TODO: Update gender in user model
                    });
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.user.gender.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: AppColors.gray400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    final GlobalKey _roleKey = GlobalKey();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Chức vụ',
              style: TextStyle(fontSize: 14, color: AppColors.gray600),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              key: _roleKey,
              onTap: () {
                final RenderBox renderBox =
                    _roleKey.currentContext!.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);
                final size = renderBox.size;

                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;

                showMenu<UserRole>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    position.dx + size.width - 100,
                    position.dy + size.height,
                    overlay.size.width - (position.dx + size.width),
                    overlay.size.height - (position.dy + size.height),
                  ),
                  items: [UserRole.worker, UserRole.sv].map((UserRole role) {
                    return PopupMenuItem<UserRole>(
                      value: role,
                      height: 36,
                      child: Text(
                        role.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray900,
                        ),
                      ),
                    );
                  }).toList(),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ).then((UserRole? selectedRole) {
                  if (selectedRole != null && selectedRole != _currentRole) {
                    setState(() {
                      _currentRole = selectedRole;
                    });
                    // Update global role for testing
                    UserProvider().setRole(selectedRole);
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _currentRole.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: AppColors.gray400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14, color: AppColors.gray900),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.brand500, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Color _getWorkStatusColor(WorkStatus status) {
    switch (status) {
      case WorkStatus.active:
        return AppColors.success500;
      case WorkStatus.onLeave:
        return AppColors.warning500;
      case WorkStatus.resigned:
        return AppColors.gray500;
    }
  }
}
