import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'config/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/report/report_list_screen.dart';
import 'screens/report/leader_report_management_screen.dart';
import 'screens/idea_box/idea_box_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/camera/camera_screen.dart'; // Import CameraScreen
import 'providers/user_provider.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentSelectedIndex = 0;
  late PageController _pageController;
  bool _isUserSwiping = false;
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _userProvider = UserProvider();

    // Listen to role changes
    _userProvider.addListener(_onRoleChanged);
  }

  void _onRoleChanged() {
    if (mounted) {
      setState(() {
        // Rebuild to reflect role changes
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _userProvider.removeListener(_onRoleChanged);
    super.dispose();
  }

  void updateCurrentIndex(int index) {
    if (currentSelectedIndex == index) return;

    setState(() {
      currentSelectedIndex = index;
    });

    if (!_isUserSwiping) {
      _pageController.jumpToPage(index);
    }
  }

  Widget _buildNavItem(int index, String iconPath) {
    final isSelected = currentSelectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => updateCurrentIndex(index),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SvgPicture.asset(
            iconPath,
            color: isSelected ? AppColors.brand500 : AppColors.gray400,
            width: 26,
            height: 26,
          ),
        ),
      ),
    );
  }

  List<Widget> get pages {
    return [
      const HomeScreen(),
      _userProvider.isLeader
          ? const LeaderReportManagementScreen()
          : const ReportListScreen(),
      const IdeaBoxListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent bottom nav from moving when keyboard appears
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _isUserSwiping = true;
                currentSelectedIndex = index;
                _isUserSwiping = false;
              });
            },
            children: pages,
          ),
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Stack(
              clipBehavior: Clip.none, // Allow overflow for floating button
              alignment: Alignment.topCenter,
              children: [
                // Bottom Navigation Bar
                Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, 'assets/home.svg'),
                      _buildNavItem(1, 'assets/report.svg'),
                      const SizedBox(width: 56), // Space for floating button
                      _buildNavItem(2, 'assets/box.svg'),
                      _buildNavItem(3, 'assets/person.svg'),
                    ],
                  ),
                ),
                // Floating Camera Button
                Positioned(
                  top: -20, // More negative to be clearly above navbar
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.error500, // DENSO Red
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error500.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: AppColors.transparent,
                      child: InkWell(
                        onTap: () async {
                          // Open CameraScreen
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CameraScreen(),
                            ),
                          );

                          // Handle returned result (photo or QR data)
                          if (result != null) {
                            // TODO: Process captured photo or scanned QR code
                            debugPrint('Camera result: $result');
                          }
                        },
                        borderRadius: BorderRadius.circular(32),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
