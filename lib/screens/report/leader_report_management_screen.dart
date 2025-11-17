import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/report_model.dart';
import 'leader_report_review_screen.dart';

/// Màn hình quản lý báo cáo sự cố cho Leader
/// Leader nhận báo cáo từ User, xác nhận và gửi lên Admin
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Mock data - will be replaced with API calls
  List<ReportModel> _getReportsByTab(int tabIndex) {
    // Tab 0: NEW (Pending approval)
    // Tab 1: PROCESSING (Approved, being handled by Admin)
    // Tab 2: COMPLETED (Closed)

    final allReports = _getMockReports();

    switch (tabIndex) {
      case 0: // NEW
        return allReports
            .where(
              (r) =>
                  r.status == ReportStatus.processing && r.id.contains('NEW'),
            )
            .toList();
      case 1: // PROCESSING
        return allReports
            .where(
              (r) =>
                  r.status == ReportStatus.processing && !r.id.contains('NEW'),
            )
            .toList();
      case 2: // COMPLETED
        return allReports
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

  List<ReportModel> _getMockReports() {
    return [
      // NEW reports (pending Leader approval)
      ReportModel(
        id: 'SC-1025-NEW',
        title: 'Máy dập Line 3 bị kẹt - Nguyễn Văn A',
        description: 'Máy không hoạt động, cần kiểm tra ngay',
        location: 'Dây chuyền A - Line 3',
        priority: ReportPriority.urgent,
        status: ReportStatus.processing,
        createdDate: DateTime.now().subtract(const Duration(hours: 2)),
        attachments: [],
      ),
      ReportModel(
        id: 'SC-1026-NEW',
        title: 'Thiếu nguyên liệu - Trần Thị B',
        description: 'Kho hết vật liệu số 245',
        location: 'Kho B',
        priority: ReportPriority.high,
        status: ReportStatus.processing,
        createdDate: DateTime.now().subtract(const Duration(hours: 5)),
        attachments: [],
      ),
      // PROCESSING reports
      ReportModel(
        id: 'SC-1020',
        title: 'Lỗi hệ thống điều khiển - Lê Văn C',
        description: 'Màn hình không hiển thị',
        location: 'Dây chuyền B',
        priority: ReportPriority.high,
        status: ReportStatus.processing,
        createdDate: DateTime.now().subtract(const Duration(days: 1)),
        attachments: [],
      ),
      // COMPLETED reports
      ReportModel(
        id: 'SC-1018',
        title: 'Hỏng băng tải - Phạm Thị D',
        description: 'Băng tải bị đứt',
        location: 'Dây chuyền C',
        priority: ReportPriority.medium,
        status: ReportStatus.completed,
        createdDate: DateTime.now().subtract(const Duration(days: 3)),
        attachments: [],
      ),
    ];
  }

  List<ReportModel> get _filteredReports {
    var reports = _getReportsByTab(_tabController.index);

    // Search filter
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

    // Priority filter
    if (_selectedFilters.isNotEmpty) {
      final hasPriorityFilter = _selectedFilters.any(
        (f) => ['urgent', 'high', 'medium', 'low'].contains(f),
      );

      if (hasPriorityFilter) {
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
    }

    return reports;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              _buildSearchAndFilter(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReportList(),
                    _buildReportList(),
                    _buildReportList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            'Quản lý Báo cáo sự cố',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
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
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('MỚI'),
                const SizedBox(width: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_getReportsByTab(0).length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ĐANG XỬ LÝ'),
                const SizedBox(width: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_getReportsByTab(1).length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const Text('HOÀN THÀNH')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(fontSize: 14, color: AppColors.gray900),
              decoration: InputDecoration(
                hintText: 'Tìm theo ID, tiêu đề, người gửi...',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.gray400),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.gray400,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.gray400,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppColors.gray600, size: 22),
            color: Colors.white,
            offset: const Offset(0, 40),
            onSelected: (_) {},
            itemBuilder: (context) => [
              // Filter menu items here
              PopupMenuItem(
                enabled: false,
                child: Text('Lọc theo mức độ ưu tiên'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    final reports = _filteredReports;

    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              'Không có báo cáo nào',
              style: TextStyle(fontSize: 16, color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return _buildReportCard(reports[index]);
      },
    );
  }

  Widget _buildReportCard(ReportModel report) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaderReportReviewScreen(report: report),
          ),
        );
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
                    report.id,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(report.priority),
                    ),
                  ),
                ),
                const Spacer(),
                if (report.id.contains('NEW'))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Chờ Leader duyệt',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              report.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: AppColors.gray500),
                const SizedBox(width: 4),
                Text(
                  report.title.contains(' - ')
                      ? report.title.split(' - ').last
                      : 'N/A',
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
