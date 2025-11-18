import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/user_profile_model.dart';
import '../../providers/user_provider.dart';
import 'pages/personal_info_screen.dart';
import 'pages/settings_screen.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_menu_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserRole _currentRole;

  @override
  void initState() {
    super.initState();
    _currentRole = UserProvider().currentRole;

    // Listen to role changes
    UserProvider().addListener(_onRoleChanged);
  }

  @override
  void dispose() {
    UserProvider().removeListener(_onRoleChanged);
    super.dispose();
  }

  void _onRoleChanged() {
    if (mounted) {
      setState(() {
        _currentRole = UserProvider().currentRole;
      });
    }
  }

  // Mock data - replace with actual user data
  UserProfile get _currentUser => UserProfile(
    id: '1',
    fullName: 'Nguyễn Văn A',
    employeeId: 'NV-2024-001',
    gender: Gender.male,
    dateOfBirth: DateTime(1990, 5, 15),
    phoneNumber: '0123456789',
    email: 'nguyenvana@denso.com',
    address: 'TP. Hồ Chí Minh',
    role: _currentRole,
    department: 'Dây chuyền sản xuất A',
    joinDate: DateTime(2020, 1, 10),
    shift: ShiftType.shift1,
    workStatus: WorkStatus.active,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Avatar and basic info
                  ProfileHeaderCard(
                    user: _currentUser,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PersonalInfoScreen(user: _currentUser),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // Red divider line
                  Container(
                    height: 1,
                    color: AppColors.brand500,
                    margin: const EdgeInsets.only(bottom: 30),
                  ),

                  // Menu options in one box
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gray200.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenuCard(
                          icon: Icons.settings_outlined,
                          title: 'Cài đặt',
                          subtitle: 'Cài đặt hệ thống',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),

                        ProfileMenuCard(
                          icon: Icons.info_outline,
                          title: 'Thông tin ứng dụng',
                          subtitle: 'Phiên bản và giấy phép',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tính năng đang phát triển'),
                              ),
                            );
                          },
                        ),

                        ProfileMenuCard(
                          icon: Icons.help_outline,
                          title: 'Trợ giúp',
                          subtitle: 'Hướng dẫn và hỗ trợ',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tính năng đang phát triển'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Logout button
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.white,
                            title: Text(
                              'Xác nhận đăng xuất',
                              style: TextStyle(color: AppColors.black),
                            ),
                            content: Text(
                              'Bạn có chắc muốn đăng xuất?',
                              style: TextStyle(color: AppColors.gray700),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(color: AppColors.gray600),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close dialog

                                  // Navigate to Login screen and clear navigation stack
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false, // Remove all routes
                                  );

                                  // TODO: Clear user session data (SharedPreferences, tokens, etc.)

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Đã đăng xuất thành công',
                                      ),
                                      backgroundColor: AppColors.success500,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brand500,
                                  foregroundColor: AppColors.white,
                                ),
                                child: const Text('Đăng xuất'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brand500,
                        side: BorderSide(color: AppColors.brand500, width: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
