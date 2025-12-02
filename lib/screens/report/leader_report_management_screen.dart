import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/report_model.dart';
import '../../services/incident_service.dart';
import '../../components/loading_infinity.dart';
import 'leader_report_review_screen.dart';

class LeaderReportManagementScreen extends StatefulWidget {
  const LeaderReportManagementScreen({super.key});

  @override
  State<LeaderReportManagementScreen> createState() =>
      _LeaderReportManagementScreenState();
}

class _LeaderReportManagementScreenState
    extends State<LeaderReportManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Set<String> _selectedFilters = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ReportModel> _allReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _fetchReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    try {
      final data = await IncidentService.getIncidents();
      setState(() {
        _allReports = data.map((json) => ReportModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<ReportModel> _getReportsByTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _allReports
            .where((r) => r.status == ReportStatus.pending)
            .toList();
      case 1:
        return _allReports
            .where((r) => r.status == ReportStatus.processing)
            .toList();
      case 2:
        return _allReports
            .where(
              (r) =>
                  r.status == ReportStatus.completed ||
                  r.status == ReportStatus.closed,
            )
            .toList();
      default:
        return [];
    }
  }

  List<ReportModel> get _filteredReports {
    var reports = _getReportsByTab(_tabController.index);
    if (_searchQuery.isNotEmpty) {
      reports = reports
          .where(
            (r) =>
                r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                r.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                r.location.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    if (_selectedFilters.isNotEmpty) {
      reports = reports.where((report) {
        return (_selectedFilters.contains('urgent') &&
                report.priority == ReportPriority.urgent) ||
            (_selectedFilters.contains('high') &&
                report.priority == ReportPriority.high) ||
            (_selectedFilters.contains('medium') &&
                report.priority == ReportPriority.medium) ||
            (_selectedFilters.contains('low') &&
                report.priority == ReportPriority.low);
      }).toList();
    }
    return reports;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(l10n),
              _buildTabBar(),
              _buildSearchAndFilter(),
              Expanded(
                child: _isLoading
                    ? const LoadingInfinity()
                    : RefreshIndicator(
                        onRefresh: _fetchReports,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildReportList(),
                            _buildReportList(),
                            _buildReportList(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/leader-report-form'),
          backgroundColor: AppColors.error500,
          icon: Icon(Icons.add, color: AppColors.white),
          label: Text(
            l10n.createReport,
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
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
            child: Icon(
              Icons.assignment_outlined,
              color: AppColors.brand500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.leaderReportManagement,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _fetchReports,
            icon: Icon(Icons.refresh, color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final pendingCount = _getReportsByTab(0).length;
    final processingCount = _getReportsByTab(1).length;
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
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('MỚI'),
                if (pendingCount > 0) ...[
                  const SizedBox(width: 3),
                  _buildBadge(pendingCount, 0),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.tabProcessing),
                if (processingCount > 0) ...[
                  const SizedBox(width: 3),
                  _buildBadge(processingCount, 1),
                ],
              ],
            ),
          ),
          Tab(child: Text(AppLocalizations.of(context)!.tabCompleted)),
        ],
      ),
    );
  }

  Widget _buildBadge(int count, int tabIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: _tabController.index == tabIndex
            ? AppColors.white
            : (tabIndex == 0 ? AppColors.error500 : AppColors.orange500),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _tabController.index == tabIndex
              ? (tabIndex == 0 ? AppColors.error500 : AppColors.orange500)
              : AppColors.white,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: l10n.searchPlaceholder,
                hintStyle: TextStyle(color: AppColors.gray400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: AppColors.gray400),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.gray400),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.brand500, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppColors.gray600),
            onSelected: (filter) => setState(() {
              if (_selectedFilters.contains(filter)) {
                _selectedFilters.remove(filter);
              } else {
                _selectedFilters.add(filter);
              }
            }),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'urgent', child: Text(l10n.priorityUrgent)),
              PopupMenuItem(value: 'high', child: Text(l10n.priorityHigh)),
              PopupMenuItem(value: 'medium', child: Text(l10n.priorityMedium)),
              PopupMenuItem(value: 'low', child: Text(l10n.priorityLow)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    final l10n = AppLocalizations.of(context)!;
    final reports = _filteredReports;
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              l10n.noReportsFound,
              style: TextStyle(fontSize: 16, color: AppColors.gray500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchReports,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.refresh),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand500,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: reports.length,
      itemBuilder: (context, index) => _buildReportCard(reports[index]),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final isPending = report.status == ReportStatus.pending;
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaderReportReviewScreen(report: report),
          ),
        );
        if (result == true) _fetchReports();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray200.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(report.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${report.id.length > 8 ? report.id.substring(0, 8) : report.id}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(report.priority),
                    ),
                  ),
                ),
                const Spacer(),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pending_actions,
                          color: AppColors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Chờ duyệt',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      report.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(report.status),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: AppColors.gray500),
                const SizedBox(width: 4),
                Text(
                  report.reporterName ?? 'N/A',
                  style: TextStyle(fontSize: 13, color: AppColors.gray600),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.gray500,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.location,
                    style: TextStyle(fontSize: 13, color: AppColors.gray600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(report.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    report.priorityLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(report.priority),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(report.createdDate),
                  style: TextStyle(fontSize: 12, color: AppColors.gray400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.low:
        return AppColors.success500;
      case ReportPriority.medium:
        return AppColors.blueLight500;
      case ReportPriority.high:
        return AppColors.orange500;
      case ReportPriority.urgent:
        return AppColors.error500;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return AppColors.error500;
      case ReportStatus.processing:
        return AppColors.orange500;
      case ReportStatus.completed:
        return AppColors.success500;
      case ReportStatus.closed:
        return AppColors.gray400;
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }
}
