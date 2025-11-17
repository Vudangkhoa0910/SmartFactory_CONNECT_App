import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../models/user_profile_model.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onTap;

  const ProfileHeaderCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(minHeight: 130),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Info on the left
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    user.fullName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Role and Employee ID
                  Text(
                    '${user.role.displayName} • ${user.employeeId}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Department
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.department,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.gray500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.gray400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Avatar on the right
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brand500, width: 0.5),
                color: Colors.transparent,
              ),
              child: user.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(user.avatarUrl!, fit: BoxFit.cover),
                    )
                  : Icon(Icons.person, size: 45, color: AppColors.brand500),
            ),
          ],
        ),
      ),
    );
  }
}
