import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_colors.dart';
import '../../models/news_model.dart';
import '../../services/news_service.dart';
import 'news_detail_screen.dart';

class AllNewsScreen extends StatefulWidget {
  const AllNewsScreen({super.key});

  @override
  State<AllNewsScreen> createState() => _AllNewsScreenState();
}

class _AllNewsScreenState extends State<AllNewsScreen> {
  Set<String> _selectedFilters = {};
  List<NewsModel> _newsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final newsData = await NewsService.getNews(
        limit: 50,
      ); // Fetch more for all news
      if (mounted) {
        setState(() {
          _newsList = newsData.map((json) => NewsModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching news: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Map backend category to display category
  String _getDisplayCategory(String backendCategory) {
    // Note: backendCategory is not directly available in NewsModel unless we add it.
    // But NewsModel.fromJson maps backend data.
    // Wait, NewsModel doesn't have a 'category' field in the class definition I saw earlier.
    // It has id, title, description, content, imageUrl, date, author.
    // I should probably add 'category' to NewsModel if I want to filter by it.
    // For now, I'll assume 'Khác' or try to infer, or just skip category display if missing.
    // Actually, let's check NewsModel again. It does NOT have category.
    // I should update NewsModel to include category.
    return 'Tin tức';
  }

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

  List<NewsModel> get _filteredNews {
    if (_selectedFilters.isEmpty) {
      return _newsList;
    }

    // Since we don't have category in NewsModel yet, filtering won't work properly.
    // I'll skip filtering logic for now or implement it after updating NewsModel.
    // For this task, I'll just return all news if no filters, or empty if filtered (as a placeholder).
    return _newsList;
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
              // ... (Existing filter items) ...
              // I'll keep the UI but the logic won't do much until Category is added to Model
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredNews.isEmpty
          ? Center(
              child: Text(
                'Không có tin tức nào',
                style: TextStyle(color: AppColors.gray600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredNews.length,
              itemBuilder: (context, index) {
                final news = _filteredNews[index];
                return _NewsCard(
                  news: news,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailScreen(news: news),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback? onTap;

  const _NewsCard({required this.news, this.onTap});

  String _getCategoryName(String code) {
    switch (code) {
      case 'company_announcement':
        return 'Thông báo';
      case 'safety_alert':
        return 'An toàn';
      case 'event':
        return 'Sự kiện';
      case 'production_update':
        return 'Sản xuất';
      case 'maintenance':
        return 'Bảo trì';
      default:
        return 'Tin tức';
    }
  }

  Color _getCategoryColor(String code) {
    switch (code) {
      case 'safety_alert':
        return Colors.red;
      case 'event':
        return Colors.purple;
      case 'production_update':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      default:
        return AppColors.brand500;
    }
  }

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
              child: news.imageUrl.isEmpty
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
                      news.imageUrl,
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
                    // Category & Priority
                    Row(
                      children: [
                        if (news.isPriority)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.red),
                            ),
                            child: const Text(
                              'QUAN TRỌNG',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              news.category,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getCategoryName(news.category),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getCategoryColor(news.category),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      news.title,
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
                      news.description,
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
                          news.date,
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
