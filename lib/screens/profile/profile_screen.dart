import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray25,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_rounded, size: 100, color: AppColors.brand500),
              const SizedBox(height: 24),
              Text(
                'Hồ sơ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Trang hồ sơ đang được phát triển',
                style: TextStyle(fontSize: 16, color: AppColors.gray600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
