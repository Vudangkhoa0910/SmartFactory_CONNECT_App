import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import 'widgets/home_header.dart';
import 'widgets/home_slider.dart';
import 'widgets/news_and_events.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight / 12;
    final sliderHeight = screenHeight / 3;
    final bottomPadding = 100.0;

    return Scaffold(
      backgroundColor: AppColors.gray25,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Content
            CustomScrollView(
              slivers: [
                // Spacer for fixed header
                SliverToBoxAdapter(
                  child: SizedBox(height: headerHeight + 16),
                ),

                // Slider Section
                SliverToBoxAdapter(
                  child: HomeSlider(height: sliderHeight),
                ),

                // News & Events Section
                SliverPadding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  sliver: const SliverToBoxAdapter(
                    child: NewsAndEvents(),
                  ),
                ),
              ],
            ),

            // Fixed Header on top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HomeHeader(height: headerHeight),
            ),
          ],
        ),
      ),
    );
  }
}
