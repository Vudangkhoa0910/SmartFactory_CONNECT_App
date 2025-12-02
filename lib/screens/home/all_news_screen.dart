import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/news_model.dart';
import '../../services/news_service.dart';
import '../../components/loading_infinity.dart';
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
      final newsData = await NewsService.getNews(limit: 50);
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

  List<NewsModel> get _filteredNews {
    if (_selectedFilters.isEmpty) {
      return _newsList;
    }
    return _newsList
        .where((news) => _selectedFilters.contains(news.category))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          l10n.newsAndEvents,
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Filter button - Copy exact từ report_list_screen
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppColors.gray600, size: 22),
            color: Colors.white,
            offset: const Offset(0, 40),
            onSelected: (_) {},
            itemBuilder: (context) => [
              // Tất cả
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
                          l10n.all,
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
              // Divider
              PopupMenuItem(
                enabled: false,
                height: 1,
                child: Divider(height: 1, color: AppColors.brand500),
              ),
              // Row 1: Thông báo | An toàn
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
                                if (_selectedFilters.contains(
                                  'company_announcement',
                                )) {
                                  _selectedFilters.remove(
                                    'company_announcement',
                                  );
                                } else {
                                  _selectedFilters.add('company_announcement');
                                }
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.announcement,
                                style: TextStyle(
                                  color:
                                      _selectedFilters.contains(
                                        'company_announcement',
                                      )
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains(
                                        'company_announcement',
                                      )
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
                                if (_selectedFilters.contains('safety_alert')) {
                                  _selectedFilters.remove('safety_alert');
                                } else {
                                  _selectedFilters.add('safety_alert');
                                }
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.categorySafety,
                                style: TextStyle(
                                  color:
                                      _selectedFilters.contains('safety_alert')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains('safety_alert')
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
              // Row 2: Sự kiện | Sản xuất
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
                                if (_selectedFilters.contains('event')) {
                                  _selectedFilters.remove('event');
                                } else {
                                  _selectedFilters.add('event');
                                }
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.event,
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
                                if (_selectedFilters.contains(
                                  'production_update',
                                )) {
                                  _selectedFilters.remove('production_update');
                                } else {
                                  _selectedFilters.add('production_update');
                                }
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.categoryProcess,
                                style: TextStyle(
                                  color:
                                      _selectedFilters.contains(
                                        'production_update',
                                      )
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains(
                                        'production_update',
                                      )
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
              // Row 3: Bảo trì | (empty)
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
                                if (_selectedFilters.contains('maintenance')) {
                                  _selectedFilters.remove('maintenance');
                                } else {
                                  _selectedFilters.add('maintenance');
                                }
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.categoryMaintenance,
                                style: TextStyle(
                                  color:
                                      _selectedFilters.contains('maintenance')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains('maintenance')
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: SizedBox()),
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
      body: _isLoading
          ? const LoadingInfinity()
          : _filteredNews.isEmpty
          ? Center(
              child: Text(
                l10n.noNewsAvailable,
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

  String _getCategoryName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'company_announcement':
        return l10n.announcement;
      case 'safety_alert':
        return l10n.categorySafety;
      case 'event':
        return l10n.event;
      case 'production_update':
        return l10n.categoryProcess;
      case 'maintenance':
        return l10n.categoryMaintenance;
      default:
        return l10n.newsTitle;
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
    final l10n = AppLocalizations.of(context)!;
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
                            child: Text(
                              l10n.priorityUrgent.toUpperCase(),
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
                            _getCategoryName(context, news.category),
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
