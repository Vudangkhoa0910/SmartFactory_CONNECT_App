import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_colors.dart';

class AllNewsScreen extends StatefulWidget {
  const AllNewsScreen({super.key});

  @override
  State<AllNewsScreen> createState() => _AllNewsScreenState();
}

class _AllNewsScreenState extends State<AllNewsScreen> {
  Set<String> _selectedFilters = {};

  final List<String> _categories = [
    'Nhân sự',
    'Sản xuất',
    'An toàn',
    'Chất lượng',
    'Sự kiện',
    'Đào tạo',
  ];

  // Map category display names to filter keys
  String _getCategoryKey(String category) {
    switch (category) {
      case 'Nhân sự':
        return 'hr';
      case 'Sản xuất':
        return 'production';
      case 'An toàn':
        return 'safety';
      case 'Chất lượng':
        return 'quality';
      case 'Sự kiện':
        return 'event';
      case 'Đào tạo':
        return 'training';
      default:
        return '';
    }
  }

  List<Map<String, String>> get _filteredNews {
    final allNews = List.generate(20, (index) {
      final category = _categories[index % _categories.length];
      return {
        'title': 'Tiêu đề tin tức số ${index + 1}',
        'description':
            'Mô tả ngắn gọn về tin tức hoặc sự kiện quan trọng trong nhà máy...',
        'date': '${index + 1} Tháng 11, 2025',
        'category': category,
        'categoryKey': _getCategoryKey(category),
        'imageUrl': '',
      };
    });

    if (_selectedFilters.isEmpty) {
      return allNews;
    }

    return allNews
        .where((news) => _selectedFilters.contains(news['categoryKey']))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.gray800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tin tức & Sự kiện',
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Filter button
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppColors.gray600, size: 22),
            color: Colors.white,
            offset: const Offset(0, 40),
            onSelected: (_) {}, // Empty handler
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, setMenuState) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilters.clear());
                        setMenuState(() {});
                      },
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Text(
                          'Tất cả',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              PopupMenuItem(
                enabled: false,
                height: 1,
                child: Divider(height: 1, color: AppColors.brand500),
              ),
              // Row 1: Nhân sự | Sản xuất
              PopupMenuItem(
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, setMenuState) {
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilters.contains('hr')
                                    ? _selectedFilters.remove('hr')
                                    : _selectedFilters.add('hr');
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Nhân sự',
                                style: TextStyle(
                                  color: _selectedFilters.contains('hr')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight: _selectedFilters.contains('hr')
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilters.contains('production')
                                    ? _selectedFilters.remove('production')
                                    : _selectedFilters.add('production');
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Sản xuất',
                                style: TextStyle(
                                  color: _selectedFilters.contains('production')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains('production')
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Row 2: An toàn | Chất lượng
              PopupMenuItem(
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, setMenuState) {
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilters.contains('safety')
                                    ? _selectedFilters.remove('safety')
                                    : _selectedFilters.add('safety');
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'An toàn',
                                style: TextStyle(
                                  color: _selectedFilters.contains('safety')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains('safety')
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilters.contains('quality')
                                    ? _selectedFilters.remove('quality')
                                    : _selectedFilters.add('quality');
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Chất lượng',
                                style: TextStyle(
                                  color: _selectedFilters.contains('quality')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains('quality')
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Row 3: Sự kiện | Đào tạo
              PopupMenuItem(
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, setMenuState) {
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilters.contains('event')
                                    ? _selectedFilters.remove('event')
                                    : _selectedFilters.add('event');
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Sự kiện',
                                style: TextStyle(
                                  color: _selectedFilters.contains('event')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight: _selectedFilters.contains('event')
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilters.contains('training')
                                    ? _selectedFilters.remove('training')
                                    : _selectedFilters.add('training');
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Đào tạo',
                                style: TextStyle(
                                  color: _selectedFilters.contains('training')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains('training')
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredNews.length,
        itemBuilder: (context, index) {
          final news = _filteredNews[index];
          return _NewsCard(
            title: news['title']!,
            description: news['description']!,
            date: news['date']!,
            category: news['category']!,
            imageUrl: news['imageUrl']!,
            onTap: () {
              // TODO: Navigate to news detail
            },
          );
        },
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String category;
  final String imageUrl;
  final VoidCallback? onTap;

  const _NewsCard({
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: imageUrl.isEmpty
                  ? Container(
                      width: 100,
                      height: 100,
                      color: AppColors.white,
                      padding: const EdgeInsets.all(16),
                      child: SvgPicture.asset(
                        'assets/logo-denso.svg',
                        fit: BoxFit.contain,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: AppColors.white,
                          padding: const EdgeInsets.all(16),
                          child: SvgPicture.asset(
                            'assets/logo-denso.svg',
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brand500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.brand500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: AppColors.gray600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
