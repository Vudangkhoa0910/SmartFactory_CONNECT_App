import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../providers/language_provider.dart';

/// Widget toggle ngôn ngữ VI | JA
/// Theme: Trắng - Đỏ đồng bộ với giao diện app
/// Compact và đẹp mắt, dễ dàng tích hợp vào bất kỳ màn hình nào
class LanguageToggleButton extends StatefulWidget {
  const LanguageToggleButton({super.key});

  @override
  State<LanguageToggleButton> createState() => _LanguageToggleButtonState();
}

class _LanguageToggleButtonState extends State<LanguageToggleButton>
    with SingleTickerProviderStateMixin {
  late LanguageProvider _languageProvider;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _languageProvider = LanguageProvider();
    _languageProvider.addListener(_onLanguageChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial state
    if (_languageProvider.isJapanese) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _languageProvider.removeListener(_onLanguageChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (_languageProvider.isJapanese) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _toggleLanguage() {
    _languageProvider.toggleLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLanguage,
      child: Container(
        width: 90,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.error500,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.error500.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final containerWidth = constraints.maxWidth;
            final containerHeight = constraints.maxHeight;
            final borderWidth = 2.0;
            
            // Tính toán kích thước nền đỏ tự động
            final slideWidth = (containerWidth - (borderWidth * 2)) / 2;
            final slideHeight = containerHeight - (borderWidth * 2);
            final slideRadius = slideHeight / 2;
            
            return Stack(
              children: [
                // Sliding background indicator
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: borderWidth + (_slideAnimation.value * slideWidth),
                      top: borderWidth,
                      child: Container(
                        width: slideWidth,
                        height: slideHeight,
                        decoration: BoxDecoration(
                          color: AppColors.error500,
                          borderRadius: BorderRadius.circular(slideRadius),
                        ),
                      ),
                    );
                  },
                ),

                // VI and JA labels
                Row(
                  children: [
                    Expanded(
                      child: _buildLanguageLabel('VI', isVietnamese: true),
                    ),
                    Expanded(
                      child: _buildLanguageLabel('JA', isVietnamese: false),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageLabel(String label, {required bool isVietnamese}) {
    final isSelected = isVietnamese
        ? _languageProvider.isVietnamese
        : _languageProvider.isJapanese;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }
}

/// Compact version - smaller for toolbars
class LanguageToggleButtonCompact extends StatelessWidget {
  const LanguageToggleButtonCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = LanguageProvider();

    return ListenableBuilder(
      listenable: languageProvider,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => languageProvider.toggleLanguage(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.error500,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageProvider.currentLocale.languageCode.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.error500,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.language,
                  color: AppColors.error500,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Icon button version - minimal for AppBar
class LanguageToggleIconButton extends StatelessWidget {
  const LanguageToggleIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = LanguageProvider();

    return ListenableBuilder(
      listenable: languageProvider,
      builder: (context, _) {
        return IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error500,
                width: 2,
              ),
            ),
            child: Text(
              languageProvider.currentLocale.languageCode.toUpperCase(),
              style: const TextStyle(
                color: AppColors.error500,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onPressed: () => languageProvider.toggleLanguage(),
          tooltip: 'Switch Language / 言語切替',
        );
      },
    );
  }
}
