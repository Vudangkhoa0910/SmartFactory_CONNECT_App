import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class AllNewsScreen extends StatefulWidget {
  const AllNewsScreen({super.key});

  @override
  State<AllNewsScreen> createState() => _AllNewsScreenState();
}

class _AllNewsScreenState extends State<AllNewsScreen> {
  String? _selectedCategory;

  final List<String> _categories = [
    'Tất cả',
    'Nhân sự',
    'Sản xuất',
    'An toàn',
    'Chất lượng',
    'Sự kiện',
    'Đào tạo',
  ];

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
          // Filter button with category label
          Row(
            children: [
              if (_selectedCategory != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brand500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _selectedCategory!,
                    style: TextStyle(
                      color: AppColors.brand500,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              PopupMenuButton<String>(
                icon: Icon(Icons.filter_list, color: AppColors.gray600),
                onSelected: (value) {
                  setState(() {
                    _selectedCategory = value == 'Tất cả' ? null : value;
                  });
                },
                itemBuilder: (context) {
                  final otherCategories = _categories
                      .where((c) => c != 'Tất cả')
                      .toList();

                  return [
                    // "Tất cả" item
                    PopupMenuItem(
                      value: 'Tất cả',
                      child: Text(
                        'Tất cả',
                        style: TextStyle(
                          fontWeight: _selectedCategory == null
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _selectedCategory == null
                              ? AppColors.error500
                              : AppColors.gray800,
                        ),
                      ),
                    ),
                    // Divider
                    PopupMenuItem(
                      enabled: false,
                      height: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 1,
                        color: AppColors.error500,
                      ),
                    ),
                    // Grid items (2 columns)
                    ...List.generate((otherCategories.length / 2).ceil(), (
                      rowIndex,
                    ) {
                      final startIndex = rowIndex * 2;
                      final endIndex = (startIndex + 2).clamp(
                        0,
                        otherCategories.length,
                      );
                      final rowCategories = otherCategories.sublist(
                        startIndex,
                        endIndex,
                      );

                      return PopupMenuItem(
                        enabled: false,
                        child: Row(
                          children: rowCategories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? AppColors.error500
                                          : AppColors.gray800,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20, // Tất cả tin tức
        itemBuilder: (context, index) {
          return _NewsCard(
            title: 'Tiêu đề tin tức số ${index + 1}',
            description:
                'Mô tả ngắn gọn về tin tức hoặc sự kiện quan trọng trong nhà máy...',
            date: '${index + 1} Tháng 11, 2025',
            category:
                _categories[(index % (_categories.length - 1)) +
                    1], // Random category
            imageUrl:
                'https://via.placeholder.com/120x80/DC2626/FFFFFF?text=News',
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
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: AppColors.gray100,
                    child: Icon(Icons.image_outlined, color: AppColors.gray400),
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
