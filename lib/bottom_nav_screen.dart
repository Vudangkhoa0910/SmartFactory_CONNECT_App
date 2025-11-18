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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void updateCurrentIndex(int index) {
    // Skip the dummy camera item (index 2)
    if (index == 2) return;

    // Adjust index for actual pages (remove dummy item from count)
    final actualIndex = index > 2 ? index - 1 : index;

    if (currentSelectedIndex == actualIndex) return;

    setState(() {
      currentSelectedIndex = actualIndex;
    });

    if (!_isUserSwiping) {
      _pageController.jumpToPage(actualIndex);
    }
  }

  List<Widget> get pages {
    final userProvider = UserProvider();
    return [
      const HomeScreen(),
      userProvider.isLeader
          ? const LeaderReportManagementScreen()
          : const ReportListScreen(),
      const IdeaBoxListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            bottom: 20,
            left: 16,
            right: 16,
            child: Stack(
              clipBehavior: Clip.none, // Allow overflow for floating button
              alignment: Alignment.topCenter,
              children: [
                // Bottom Navigation Bar
                Container(
                  height: 70,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BottomNavigationBar(
                      onTap: updateCurrentIndex,
                      currentIndex: currentSelectedIndex < 2
                          ? currentSelectedIndex
                          : currentSelectedIndex +
                                1, // Adjust for dummy item at index 2
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor:
                          AppColors.white, // Set explicit white background
                      elevation: 0,
                      enableFeedback: false,
                      items: [
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            'assets/home.svg',
                            color: AppColors.gray400,
                            width: 26,
                            height: 25,
                          ),
                          activeIcon: SvgPicture.asset(
                            'assets/home.svg',
                            color: AppColors.brand500,
                            width: 26,
                            height: 25,
                          ),
                          label: "Home",
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            'assets/report.svg',
                            color: AppColors.gray400,
                            width: 26,
                            height: 25,
                          ),
                          activeIcon: SvgPicture.asset(
                            'assets/report.svg',
                            color: AppColors.brand500,
                            width: 26,
                            height: 25,
                          ),
                          label: "Báo cáo",
                        ),
                        // Empty item for center button space
                        BottomNavigationBarItem(
                          icon: SizedBox(width: 26, height: 25),
                          label: "",
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            'assets/box.svg',
                            color: AppColors.gray400,
                            width: 26,
                            height: 25,
                          ),
                          activeIcon: SvgPicture.asset(
                            'assets/box.svg',
                            color: AppColors.brand500,
                            width: 26,
                            height: 25,
                          ),
                          label: "Hòm thư góp ý",
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            'assets/person.svg',
                            color: AppColors.gray400,
                            width: 26,
                            height: 25,
                          ),
                          activeIcon: SvgPicture.asset(
                            'assets/person.svg',
                            color: AppColors.brand500,
                            width: 26,
                            height: 25,
                          ),
                          label: "Profile",
                        ),
                      ],
                    ),
                  ),
                ),
                // Floating Camera Button
                Positioned(
                  top: -15, // More negative to be clearly above navbar
                  child: Container(
                    width: 64,
                    height: 64,
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
                            size: 30,
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
