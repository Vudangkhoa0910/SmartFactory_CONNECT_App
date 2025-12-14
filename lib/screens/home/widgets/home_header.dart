import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../providers/user_provider.dart';
import '../../../services/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/language_toggle_button.dart';

class HomeHeader extends StatefulWidget {
  final double height;

  const HomeHeader({super.key, required this.height});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      // First try cached data from UserProvider (fastest)
      final cachedData = UserProvider().cachedProfileData;
      if (cachedData != null && cachedData['full_name'] != null) {
        if (mounted) {
          setState(() {
            _userName = cachedData['full_name'];
            _isLoading = false;
          });
        }
        return;
      }

      // Then try local storage
      final userInfo = await AuthService().getUserInfo();
      if (mounted &&
          userInfo['fullName'] != null &&
          userInfo['fullName']!.isNotEmpty) {
        setState(() {
          _userName = userInfo['fullName']!;
          _isLoading = false;
        });
        return;
      }

      // Finally try API with caching
      final profileData = await UserProvider().getProfileData();
      if (mounted) {
        if (profileData != null && profileData['full_name'] != null) {
          setState(() {
            _userName = profileData['full_name'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = UserProvider();
    final bool isLeader = userProvider.isLeader;
    final l10n = AppLocalizations.of(context)!;

    // Display user name or fallback to greeting
    final displayName = _userName.isNotEmpty
        ? _userName
        : l10n.homeGreeting('');

    return Container(
      height: widget.height,
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
                _isLoading ? '...' : displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              Text(
                isLeader ? l10n.roleLeader : l10n.roleWorker,
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
              // Language toggle
              const LanguageToggleButtonCompact(),
              const SizedBox(width: 12),
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
