import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/user_profile_model.dart';
import 'pages/personal_info_screen.dart';
import 'pages/settings_screen.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_menu_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
    role: UserRole.worker,
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
                  // Menu options
                  ProfileMenuCard(
                    icon: Icons.settings_outlined,
                    title: 'Cài đặt',
                    subtitle: 'Cấu hình server backend',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
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
