import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../config/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/news_model.dart';
import '../../../services/news_service.dart';
import '../all_news_screen.dart';
import '../news_detail_screen.dart';
import '../../../components/loading_infinity.dart';

class NewsAndEvents extends StatefulWidget {
  const NewsAndEvents({super.key});

  @override
  State<NewsAndEvents> createState() => _NewsAndEventsState();
}

class _NewsAndEventsState extends State<NewsAndEvents> {
  List<NewsModel> _newsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final newsData = await NewsService.getNews(limit: 5);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.newsAndEvents,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray800,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllNewsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    l10n.seeAll,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.brand500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // News List
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: LoadingInfinity(),
              ),
            )
          else if (_newsList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  l10n.noNewsAvailable,
                  style: TextStyle(color: AppColors.gray600),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _newsList.length,
              itemBuilder: (context, index) {
                final news = _newsList[index];
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
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback onTap;

  const _NewsCard({required this.news, required this.onTap});

  String _getCategoryName(String code, AppLocalizations l10n) {
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                              style: const TextStyle(
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
                            _getCategoryName(news.category, l10n),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getCategoryColor(news.category),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
