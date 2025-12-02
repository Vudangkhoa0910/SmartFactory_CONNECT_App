import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../config/app_colors.dart';

class LoadingInfinity extends StatelessWidget {
  final double size;
  const LoadingInfinity({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(
          AppColors.brand500,
          BlendMode.srcIn,
        ),
        child: Lottie.asset(
          'assets/lottie/loading_infinity.json',
          width: size,
          height: size,
        ),
      ),
    );
  }
}
