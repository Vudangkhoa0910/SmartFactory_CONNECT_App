import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/auth/login_screen.dart';
import 'bottom_nav_screen.dart';
import 'config/app_colors.dart';
import 'services/auth_service.dart';
import 'providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Fade in the logo
    Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });

    // Check login status and navigate
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Initialize auth service (load token)
    await _authService.initialize();

    // Delay for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is logged in (local check)
    final isLoggedIn = await _authService.isLoggedIn();

    if (isLoggedIn) {
      // Verify token with backend - if backend is down, force re-login
      final isTokenValid = await _authService.verifyTokenWithBackend();

      if (!isTokenValid) {
        // Token invalid or backend unreachable - clear session and go to login
        await _authService.logout();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      // Load user info
      final userInfo = await _authService.getUserInfo();
      if (userInfo['role'] != null) {
        UserProvider().setUserRole(userInfo['role']!);
      }

      // Navigate to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    } else {
      // Navigate to login
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
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
