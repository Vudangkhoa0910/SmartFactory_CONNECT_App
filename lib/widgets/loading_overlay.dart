import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../config/app_colors.dart';

/// Loading overlay component
/// Hiển thị animation loading ở giữa màn hình với background mờ
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     // Your main content
///     MyMainWidget(),
///
///     // Loading overlay
///     LoadingOverlay(isLoading: _isLoading),
///   ],
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final double? size;
  final Color? backgroundColor;
  final double? opacity;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.size = 150,
    this.backgroundColor,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      color: (backgroundColor ?? Colors.black).withOpacity(opacity ?? 0.5),
      child: Center(
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            AppColors.error500, // DENSO Red
            BlendMode.srcATop,
          ),
          child: Lottie.asset(
            'assets/lottie/loading_infinity.json',
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }
}
