import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'bottom_nav_screen.dart';
import 'config/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Fade in the logo
    Timer(const Duration(milliseconds: 100), () {
      setState(() => _opacity = 1.0);
    });

    // After 2 seconds go to the bottom navigation screen
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _opacity,
          child: SvgPicture.asset(
            'assets/logo-denso.svg',
            width: 220,
            semanticsLabel: 'Denso Logo',
          ),
        ),
      ),
    );
  }
}

// Simple placeholder home shown after the splash. Main app can replace this.
// After the splash we navigate to `BottomNavScreen` (implemented in
// `lib/bottom_nav_screen.dart`). The previous placeholder home was removed.
