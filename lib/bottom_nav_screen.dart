import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'config/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/report/report_screen.dart';
import 'screens/suggestions/suggestions_screen.dart';
import 'screens/profile/profile_screen.dart';

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
    if (currentSelectedIndex == index) return;

    setState(() {
      currentSelectedIndex = index;
    });

    if (!_isUserSwiping) {
      _pageController.jumpToPage(index);
    }
  }

  final pages = [
    const HomeScreen(),
    const ReportScreen(),
    const SuggestionsScreen(),
    const ProfileScreen(),
  ];

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
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
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
                  currentIndex: currentSelectedIndex,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
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
          ),
        ],
      ),
    );
  }
}
