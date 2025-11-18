import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/auth/login_screen.dart';
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

    // After 2 seconds go to the login screen
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
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

// App flow: SplashScreen (2s) → LoginScreen → (after login) → BottomNavScreen (Home)
// User must login before accessing the main app
