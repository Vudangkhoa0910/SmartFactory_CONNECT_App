import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
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
                  l10n.notifications,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.pageDeveloping,
                  style: TextStyle(fontSize: 16, color: AppColors.gray600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
