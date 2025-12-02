import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../models/user_profile_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/toast_utils.dart';
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
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isEditing = false;
    });
    ToastUtils.showSuccess(l10n.success);
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
          AppLocalizations.of(context)!.personalInfo,
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
                    AppLocalizations.of(context)!.profilePhoto,
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
            _buildSection(AppLocalizations.of(context)!.personalInfo, [
              _buildInfoField(
                AppLocalizations.of(context)!.fullName,
                widget.user.fullName,
                false,
              ),
              _buildInfoField(
                AppLocalizations.of(context)!.employeeCode,
                widget.user.employeeId,
                false,
              ),
              _buildInfoField(
                AppLocalizations.of(context)!.gender,
                widget.user.gender.displayName,
                false,
              ),
              _buildInfoField(
                AppLocalizations.of(context)!.dateOfBirth,
                '${widget.user.dateOfBirth.day}/${widget.user.dateOfBirth.month}/${widget.user.dateOfBirth.year}',
                false,
              ),
              _isEditing
                  ? _buildEditField(
                      AppLocalizations.of(context)!.phone,
                      _phoneController,
                    )
                  : _buildInfoField(
                      AppLocalizations.of(context)!.phone,
                      widget.user.phoneNumber,
                      true,
                    ),
              _isEditing
                  ? _buildEditField(
                      AppLocalizations.of(context)!.email,
                      _emailController,
                    )
                  : _buildInfoField(
                      AppLocalizations.of(context)!.email,
                      widget.user.email,
                      true,
                    ),
              _buildInfoField(
                AppLocalizations.of(context)!.address,
                widget.user.address ?? AppLocalizations.of(context)!.notUpdated,
                false,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection(AppLocalizations.of(context)!.workInfo, [
              _buildInfoField(
                AppLocalizations.of(context)!.position,
                _currentRole.displayName,
                false,
              ),
              _buildInfoField(
                AppLocalizations.of(context)!.department,
                widget.user.department,
                false,
              ),
              _buildInfoField(
                AppLocalizations.of(context)!.joinDate,
                '${widget.user.joinDate.day}/${widget.user.joinDate.month}/${widget.user.joinDate.year}',
                false,
              ),
              _buildInfoField(
                AppLocalizations.of(context)!.workShift,
                widget.user.shift.displayName,
                false,
              ),
              _buildInfoField(
                AppLocalizations.of(context)!.workStatus,
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
                    AppLocalizations.of(context)!.save.toUpperCase(),
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
    final l10n = AppLocalizations.of(context)!;
    // Determine edit parameters based on label
    String getEditTitle() {
      if (label == l10n.fullName) return '${l10n.edit} ${l10n.fullName}';
      if (label == l10n.phone) return '${l10n.edit} ${l10n.phone}';
      if (label == l10n.email) return '${l10n.edit} ${l10n.email}';
      if (label == l10n.address) return '${l10n.edit} ${l10n.address}';
      return l10n.edit;
    }

    IconData getIcon() {
      if (label == l10n.fullName) return Icons.person_outline;
      if (label == l10n.phone) return Icons.phone_outlined;
      if (label == l10n.email) return Icons.email_outlined;
      if (label == l10n.address) return Icons.location_on_outlined;
      return Icons.edit_outlined;
    }

    int getMaxLines() {
      if (label == l10n.address) return 3;
      return 1;
    }

    void updateValue(String newValue) {
      if (label == l10n.fullName) {
        // TODO: Update fullName in user model
      } else if (label == l10n.phone) {
        _phoneController.text = newValue;
      } else if (label == l10n.email) {
        _emailController.text = newValue;
      } else if (label == l10n.address) {
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
