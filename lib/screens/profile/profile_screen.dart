import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/user_profile_model.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
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

  // User data based on current role
  UserProfile get _currentUser {
    if (_currentRole == UserRole.sv) {
      // Leader profile
      return UserProfile(
        id: 'MGR001',
        fullName: 'Trần Thị Quản Lý',
        employeeId: 'MGR001',
        gender: Gender.female,
        dateOfBirth: DateTime(1985, 3, 20),
        phoneNumber: '0987654321',
        email: 'manager@denso.com',
        address: 'Quận 1, TP. Hồ Chí Minh',
        role: _currentRole,
        department: 'Quản lý sản xuất',
        joinDate: DateTime(2018, 6, 15),
        shift: ShiftType.shift1,
        workStatus: WorkStatus.active,
      );
    } else {
      // Worker profile
      return UserProfile(
        id: 'EMP001',
        fullName: 'Nguyễn Văn Công Nhân',
        employeeId: 'EMP001',
        gender: Gender.male,
        dateOfBirth: DateTime(1992, 8, 10),
        phoneNumber: '0123456789',
        email: 'worker@denso.com',
        address: 'Quận 7, TP. Hồ Chí Minh',
        role: _currentRole,
        department: 'Dây chuyền sản xuất A',
        joinDate: DateTime(2020, 1, 10),
        shift: ShiftType.shift1,
        workStatus: WorkStatus.active,
      );
    }
  }

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

                  const SizedBox(height: 20),

                  // Additional menu section
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
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
                          icon: Icons.history,
                          title: 'Lịch sử hoạt động',
                          subtitle: 'Xem lại các hoạt động đã thực hiện',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tính năng đang phát triển'),
                              ),
                            );
                          },
                        ),

                        ProfileMenuCard(
                          icon: Icons.notifications_outlined,
                          title: 'Thông báo',
                          subtitle: 'Cài đặt thông báo',
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
                                onPressed: () async {
                                  Navigator.pop(context); // Close dialog

                                  // Clear user session using AuthService
                                  await AuthService().logout();

                                  // Navigate to Login screen and clear navigation stack
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/login',
                                      (route) => false, // Remove all routes
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Đã đăng xuất thành công',
                                        ),
                                        backgroundColor: AppColors.success500,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
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
