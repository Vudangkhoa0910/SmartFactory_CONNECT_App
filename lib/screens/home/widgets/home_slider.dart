import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../config/app_colors.dart';

class HomeSlider extends StatefulWidget {
  final double height;

  const HomeSlider({super.key, required this.height});

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  int _currentSlide = 0;

  final List<String> _sliderImages = [
    'https://via.placeholder.com/800x400/DC2626/FFFFFF?text=Slide+1',
    'https://via.placeholder.com/800x400/DC2626/FFFFFF?text=Slide+2',
    'https://via.placeholder.com/800x400/DC2626/FFFFFF?text=Slide+3',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              options: CarouselOptions(
                height: widget.height - 40,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentSlide = index;
                  });
                },
              ),
              items: _sliderImages.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gray300.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: AppColors.gray400,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // Slider Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _sliderImages.asMap().entries.map((entry) {
              return Container(
                width: _currentSlide == entry.key ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentSlide == entry.key
                      ? AppColors.brand500
                      : AppColors.gray300,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
