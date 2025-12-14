import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/set_utils.dart';
import '../../models/idea_box_model.dart';
import '../../services/idea_service.dart';
import 'create_idea_screen.dart';
import 'idea_detail_screen.dart';
import '../../components/loading_infinity.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

/// Màn hình danh sách Hòm thư góp ý (Idea Box)
/// Bao gồm tab Hòm thư trắng (công khai) và Hòm thư hồng (ẩn danh)
class IdeaBoxListScreen extends StatefulWidget {
  const IdeaBoxListScreen({super.key});

  @override
  State<IdeaBoxListScreen> createState() => _IdeaBoxListScreenState();
}

class _IdeaBoxListScreenState extends State<IdeaBoxListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Set<String> _selectedFilters = {};
  final IdeaService _ideaService = IdeaService();

  List<IdeaBoxItem> _whiteBoxIdeas = [];
  List<IdeaBoxItem> _pinkBoxIdeas = [];
  bool _isLoadingWhite = true;
  bool _isLoadingPink = true;
  String? _errorWhite;
  String? _errorPink;
  
  // Cached filtered results for performance
  List<IdeaBoxItem>? _cachedWhiteFiltered;
  List<IdeaBoxItem>? _cachedPinkFiltered;
  Set<String>? _lastFilters;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchIdeas(IdeaBoxType.white);
    _fetchIdeas(IdeaBoxType.pink);
  }

  Future<void> _fetchIdeas(IdeaBoxType type) async {
    setState(() {
      if (type == IdeaBoxType.white) {
        _isLoadingWhite = true;
        _errorWhite = null;
        _cachedWhiteFiltered = null; // Invalidate cache
      } else {
        _isLoadingPink = true;
        _errorPink = null;
        _cachedPinkFiltered = null; // Invalidate cache
      }
    });

    try {
      final ideas = await _ideaService.getIdeas(type: type);
      if (mounted) {
        setState(() {
          if (type == IdeaBoxType.white) {
            _whiteBoxIdeas = ideas;
            _isLoadingWhite = false;
          } else {
            _pinkBoxIdeas = ideas;
            _isLoadingPink = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (type == IdeaBoxType.white) {
            _errorWhite = e.toString();
            _isLoadingWhite = false;
          } else {
            _errorPink = e.toString();
            _isLoadingPink = false;
          }
        });
      }
    }
  }
  
  // Get cached or compute filtered ideas
  List<IdeaBoxItem> _getFilteredIdeas(IdeaBoxType type, List<IdeaBoxItem> ideas) {
    // Check cache validity
    final isWhite = type == IdeaBoxType.white;
    final cached = isWhite ? _cachedWhiteFiltered : _cachedPinkFiltered;
    
    if (cached != null && _lastFilters != null && setEquals(_lastFilters!, _selectedFilters)) {
      return cached;
    }
    
    // Compute filtered results
    List<IdeaBoxItem> filtered;
    if (_selectedFilters.isEmpty) {
      filtered = ideas;
    } else {
      filtered = ideas.where((idea) {
        // Kiểm tra loại (type)
        final hasTypeFilter = _selectedFilters.any(
          (f) => ['quality', 'safety', 'process'].contains(f),
        );
        final matchesType =
            !hasTypeFilter ||
            (_selectedFilters.contains('quality') &&
                idea.issueType == IssueType.quality) ||
            (_selectedFilters.contains('safety') &&
                idea.issueType == IssueType.safety) ||
            (_selectedFilters.contains('process') &&
                idea.issueType == IssueType.process);

        // Kiểm tra trạng thái (status)
        final hasStatusFilter = _selectedFilters.any(
          (f) => ['underReview', 'approved', 'completed'].contains(f),
        );
        final matchesStatus =
            !hasStatusFilter ||
            (_selectedFilters.contains('underReview') &&
                idea.status == IdeaStatus.underReview) ||
            (_selectedFilters.contains('approved') &&
                idea.status == IdeaStatus.approved) ||
            (_selectedFilters.contains('completed') &&
                idea.status == IdeaStatus.completed);

        return matchesType && matchesStatus;
      }).toList();
    }
    
    // Cache results
    if (isWhite) {
      _cachedWhiteFiltered = filtered;
    } else {
      _cachedPinkFiltered = filtered;
    }
    _lastFilters = Set.from(_selectedFilters);
    
    return filtered;
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.appBackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(
                height: 0,
              ), // Spacing consistency with Leader Report
              _buildTabBar(),
              const SizedBox(height: 20), // Match spacing after TabBar
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIdeaList(IdeaBoxType.white),
                    _buildIdeaList(IdeaBoxType.pink),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brand50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.mail_outline,
              color: AppColors.brand500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.ideaBox,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const Spacer(),
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
                          l10n.ideaStatusAll,
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
              // Row 1: An toàn | Đang xem xét
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
                                l10n.ideaCategorySafety,
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
                                _selectedFilters.contains('underReview')
                                    ? _selectedFilters.remove('underReview')
                                    : _selectedFilters.add('underReview');
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.ideaStatusUnderReview,
                                style: TextStyle(
                                  color:
                                      _selectedFilters.contains('underReview')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains('underReview')
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
              // Row 2: Chất lượng | Đã phê duyệt
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
                                l10n.ideaCategoryQuality,
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilters.contains('approved')
                                    ? _selectedFilters.remove('approved')
                                    : _selectedFilters.add('approved');
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.ideaStatusApproved,
                                style: TextStyle(
                                  color: _selectedFilters.contains('approved')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains('approved')
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
              // Row 3: Quy trình | Hoàn thành
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
                                _selectedFilters.contains('process')
                                    ? _selectedFilters.remove('process')
                                    : _selectedFilters.add('process');
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.ideaCategoryProductivity,
                                style: TextStyle(
                                  color: _selectedFilters.contains('process')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains('process')
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
                                _selectedFilters.contains('completed')
                                    ? _selectedFilters.remove('completed')
                                    : _selectedFilters.add('completed');
                              });
                              setMenuState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.ideaStatusImplemented,
                                style: TextStyle(
                                  color: _selectedFilters.contains('completed')
                                      ? AppColors.brand500
                                      : Colors.black,
                                  fontSize: 13,
                                  fontWeight:
                                      _selectedFilters.contains('completed')
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
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 45,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.error500,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.gray900,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) => setState(() {}),
        tabs: [
          Tab(text: l10n.whiteBoxTab),
          Tab(text: l10n.pinkBoxTab),
        ],
      ),
    );
  }

  Widget _buildIdeaList(IdeaBoxType type) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = type == IdeaBoxType.white
        ? _isLoadingWhite
        : _isLoadingPink;
    final error = type == IdeaBoxType.white ? _errorWhite : _errorPink;
    final ideas = type == IdeaBoxType.white ? _whiteBoxIdeas : _pinkBoxIdeas;

    if (isLoading) {
      return const Center(child: LoadingInfinity());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${l10n.error}: $error',
              style: TextStyle(color: AppColors.error500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchIdeas(type),
              child: Text(l10n.refresh),
            ),
          ],
        ),
      );
    }

    // Áp dụng bộ lọc với caching
    final filteredIdeas = _getFilteredIdeas(type, ideas);

    if (filteredIdeas.isEmpty) {
      return _buildEmptyState(type);
    }

    return CustomRefreshIndicator(
      onRefresh: () => _fetchIdeas(type),
      builder:
          (BuildContext context, Widget child, IndicatorController controller) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                if (!controller.isIdle)
                  Positioned(
                    top: 10.0 * controller.value,
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
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          20,
          0, // Top padding removed - spacing handled by SizedBox after TabBar
          20,
          120,
        ), // Bottom padding để tránh bottom nav
        itemCount: filteredIdeas.length,
        itemBuilder: (context, index) {
          return _buildIdeaCard(filteredIdeas[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(IdeaBoxType type) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: type == IdeaBoxType.white
                  ? AppColors.brand50
                  : AppColors.themePink500.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              type == IdeaBoxType.white
                  ? Icons.inbox_outlined
                  : Icons.favorite_border,
              size: 64,
              color: type == IdeaBoxType.white
                  ? AppColors.brand500
                  : AppColors.themePink500,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            type == IdeaBoxType.white ? l10n.noIdeasYet : l10n.noIdeasYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            type == IdeaBoxType.white
                ? l10n.createFirstIdea
                : l10n.createFirstIdea,
            style: TextStyle(fontSize: 14, color: AppColors.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(IdeaBoxItem idea) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand500.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IdeaDetailScreen(idea: idea),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatusBadge(idea.status),
                    const Spacer(),
                    _buildIssueTypeChip(idea.issueType),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  idea.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  idea.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.gray100, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (idea.senderName != null && idea.senderName!.isNotEmpty) ...[
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.brand100,
                        child: Text(
                          idea.senderName![0],
                          style: const TextStyle(
                            color: AppColors.brand600,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              idea.senderName!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                            ),
                            Text(
                              idea.senderDepartment ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.privacy_tip,
                        size: 16,
                        color: AppColors.themePink500,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.ideaStatusDraft,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.gray500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      _formatDate(idea.createdAt),
                      style: TextStyle(fontSize: 12, color: AppColors.gray400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(IdeaStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case IdeaStatus.submitted:
        backgroundColor = AppColors.gray100;
        textColor = AppColors.gray700;
        icon = Icons.send;
        break;
      case IdeaStatus.underReview:
        backgroundColor = AppColors.blueLight100;
        textColor = AppColors.blueLight700;
        icon = Icons.visibility;
        break;
      case IdeaStatus.escalated:
        backgroundColor = AppColors.orange100;
        textColor = AppColors.orange700;
        icon = Icons.arrow_upward;
        break;
      case IdeaStatus.approved:
        backgroundColor = AppColors.success100;
        textColor = AppColors.success700;
        icon = Icons.check_circle;
        break;
      case IdeaStatus.rejected:
        backgroundColor = AppColors.error100;
        textColor = AppColors.error700;
        icon = Icons.cancel;
        break;
      case IdeaStatus.implementing:
        backgroundColor = AppColors.warning100;
        textColor = AppColors.warning700;
        icon = Icons.engineering;
        break;
      case IdeaStatus.completed:
        backgroundColor = AppColors.success100;
        textColor = AppColors.success700;
        icon = Icons.done_all;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueTypeChip(IssueType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brand50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brand200),
      ),
      child: Text(
        type.label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.brand700,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 80), // Đẩy lên khỏi bottom nav
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateIdeaScreen(
                initialBoxType: _tabController.index == 0
                    ? IdeaBoxType.white
                    : IdeaBoxType.pink,
              ),
            ),
          );

          if (result == true) {
            _fetchIdeas(IdeaBoxType.white);
            _fetchIdeas(IdeaBoxType.pink);
          }
        },
        backgroundColor: AppColors.brand500,
        elevation: 4,
        icon: const Icon(Icons.add, color: AppColors.white, size: 22),
        label: Text(
          l10n.submitIdea,
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
