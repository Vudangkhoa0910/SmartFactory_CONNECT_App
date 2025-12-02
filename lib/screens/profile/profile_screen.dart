import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/toast_utils.dart';
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
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentRole = UserProvider().currentRole;
    _loadUserProfile();

    // Listen to role changes
    UserProvider().addListener(_onRoleChanged);
  }

  @override
  void dispose() {
    UserProvider().removeListener(_onRoleChanged);
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userInfo = await AuthService().getUserInfo();
      if (mounted) {
        setState(() {
          _userProfile = UserProfile(
            id: userInfo['username'] ?? 'EMP001',
            fullName: userInfo['fullName'] ?? '',
            employeeId: userInfo['username'] ?? 'EMP001',
            gender: Gender.male,
            dateOfBirth: DateTime(1992, 8, 10),
            phoneNumber: '',
            email: '',
            address: '',
            role: _currentRole,
            department: '',
            joinDate: DateTime.now(),
            shift: ShiftType.shift1,
            workStatus: WorkStatus.active,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onRoleChanged() {
    if (mounted) {
      setState(() {
        _currentRole = UserProvider().currentRole;
      });
      _loadUserProfile();
    }
  }

  // User data based on current role (fallback if no user info)
  UserProfile get _currentUser {
    if (_userProfile != null) {
      return _userProfile!;
    }

    // Fallback to default profile
    if (_currentRole == UserRole.sv) {
      // Leader profile
      return UserProfile(
        id: 'MGR001',
        fullName: 'Leader',
        employeeId: 'MGR001',
        gender: Gender.female,
        dateOfBirth: DateTime(1985, 3, 20),
        phoneNumber: '',
        email: '',
        address: '',
        role: _currentRole,
        department: '',
        joinDate: DateTime(2018, 6, 15),
        shift: ShiftType.shift1,
        workStatus: WorkStatus.active,
      );
    } else {
      // Worker profile
      return UserProfile(
        id: 'EMP001',
        fullName: 'Worker',
        employeeId: 'EMP001',
        gender: Gender.male,
        dateOfBirth: DateTime(1992, 8, 10),
        phoneNumber: '',
        email: '',
        address: '',
        role: _currentRole,
        department: '',
        joinDate: DateTime(2020, 1, 10),
        shift: ShiftType.shift1,
        workStatus: WorkStatus.active,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                          title: l10n.settings,
                          subtitle: l10n.general,
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
                          title: l10n.about,
                          subtitle: l10n.version,
                          onTap: () {
                            ToastUtils.showInfo(l10n.loading);
                          },
                        ),

                        ProfileMenuCard(
                          icon: Icons.help_outline,
                          title: l10n.helpSupport,
                          subtitle: l10n.feedback,
                          onTap: () {
                            ToastUtils.showInfo(l10n.loading);
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
                          title: l10n.reportHistory,
                          subtitle: l10n.seeAll,
                          onTap: () {
                            ToastUtils.showInfo(l10n.loading);
                          },
                        ),

                        ProfileMenuCard(
                          icon: Icons.notifications_outlined,
                          title: l10n.notifications,
                          subtitle: l10n.notificationSettings,
                          onTap: () {
                            ToastUtils.showInfo(l10n.loading);
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
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.white,
                            title: Text(
                              l10n.logoutConfirmTitle,
                              style: TextStyle(color: AppColors.black),
                            ),
                            content: Text(
                              l10n.logoutConfirmMessage,
                              style: TextStyle(color: AppColors.gray700),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(
                                  l10n.cancel,
                                  style: TextStyle(color: AppColors.gray600),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(ctx); // Close dialog

                                  // Clear user session using AuthService
                                  await AuthService().logout();

                                  // Show toast BEFORE navigation
                                  ToastUtils.showSuccess(l10n.logout);

                                  // Navigate to Login screen and clear navigation stack
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/login',
                                      (route) => false, // Remove all routes
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brand500,
                                  foregroundColor: AppColors.white,
                                ),
                                child: Text(l10n.logout),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(
                        l10n.logout,
                        style: const TextStyle(
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
