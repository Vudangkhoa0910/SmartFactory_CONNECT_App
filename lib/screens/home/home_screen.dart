import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../config/app_colors.dart';
import '../../components/loading_infinity.dart';
import 'widgets/home_header.dart';
import 'widgets/home_slider.dart';
import 'widgets/news_and_events.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Key để refresh child widgets
  Key _refreshKey = UniqueKey();

  Future<void> _onRefresh() async {
    // Đợi một chút để animation hiển thị
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _refreshKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight / 12;
    final sliderHeight = screenHeight / 3;
    final bottomPadding = 100.0;

    return Scaffold(
      body: RepaintBoundary(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBackgroundGradient,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Scrollable Content with CustomRefreshIndicator
                CustomRefreshIndicator(
                  onRefresh: _onRefresh,
                  builder:
                      (
                        BuildContext context,
                        Widget child,
                        IndicatorController controller,
                      ) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            if (!controller.isIdle)
                              Positioned(
                                top: headerHeight + 10.0 * controller.value,
                                child: const SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: LoadingInfinity(size: 80),
                                ),
                              ),
                            Transform.translate(
                              offset: Offset(0, 100.0 * controller.value),
                              child: child,
                            ),
                          ],
                        );
                      },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      // Spacer for fixed header
                      SliverToBoxAdapter(
                        child: SizedBox(height: headerHeight + 16),
                      ),

                      // Slider Section
                      SliverToBoxAdapter(
                        child: HomeSlider(
                          key: _refreshKey,
                          height: sliderHeight,
                        ),
                      ),

                      // News & Events Section
                      SliverPadding(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        sliver: SliverToBoxAdapter(
                          child: NewsAndEvents(key: ValueKey(_refreshKey)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Fixed Header on top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: RepaintBoundary(
                    child: HomeHeader(height: headerHeight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
