import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray25,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_rounded,
                size: 100,
                color: AppColors.brand500,
              ),
              const SizedBox(height: 24),
              Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Trang thông báo đang được phát triển',
                style: TextStyle(fontSize: 16, color: AppColors.gray600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
