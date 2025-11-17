import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../providers/user_provider.dart';

class HomeHeader extends StatelessWidget {
  final double height;

  const HomeHeader({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final userProvider = UserProvider();
    final bool isLeader = userProvider.isLeader;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nguyễn Văn A',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              Text(
                isLeader ? 'Leader' : 'Worker',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isLeader ? AppColors.error500 : AppColors.gray800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          // Icons bên phải
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: AppColors.gray600, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.gray600,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error500,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
