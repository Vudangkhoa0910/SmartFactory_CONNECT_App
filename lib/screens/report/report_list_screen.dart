import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import 'report_form_screen.dart';
import 'report_detail_view_screen.dart';
import '../../models/report_model.dart';
import '../../services/incident_service.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  Set<String> _selectedFilters = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await IncidentService.getIncidents();
      setState(() {
        _reports = data.map((json) => ReportModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching reports: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<ReportModel> get _filteredReports {
    var reports = _reports;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      reports = reports.where((r) {
        return r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.location.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Category filters
    if (_selectedFilters.isEmpty) return reports;

    return reports.where((report) {
      // Check priority match
      bool matchesPriority =
          !_selectedFilters.any(
            (f) => ['urgent', 'high', 'medium', 'low'].contains(f),
          ) ||
          (_selectedFilters.contains('urgent') &&
              report.priority == ReportPriority.urgent) ||
          (_selectedFilters.contains('high') &&
              report.priority == ReportPriority.high) ||
          (_selectedFilters.contains('medium') &&
              report.priority == ReportPriority.medium) ||
          (_selectedFilters.contains('low') &&
              report.priority == ReportPriority.low);

      // Check status match
      bool matchesStatus =
          !_selectedFilters.any(
            (f) => ['processing', 'completed', 'closed'].contains(f),
          ) ||
          (_selectedFilters.contains('processing') &&
              report.status == ReportStatus.processing) ||
          (_selectedFilters.contains('completed') &&
              report.status == ReportStatus.completed) ||
          (_selectedFilters.contains('closed') &&
              report.status == ReportStatus.closed);

      return matchesPriority && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.processing:
        return AppColors.orange500;
      case ReportStatus.completed:
        return AppColors.success500;
      case ReportStatus.closed:
        return AppColors.gray400;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ReportFormScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const curve = Curves.easeInOutCubic;

                      var scaleTween = Tween<double>(
                        begin: 0.85,
                        end: 1.0,
                      ).chain(CurveTween(curve: curve));
                      var scaleAnimation = animation.drive(scaleTween);

                      var fadeTween = Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).chain(CurveTween(curve: curve));
                      var fadeAnimation = animation.drive(fadeTween);

                      var radiusTween = Tween<double>(
                        begin: 40.0,
                        end: 0.0,
                      ).chain(CurveTween(curve: curve));
                      var radiusAnimation = animation.drive(radiusTween);

                      return ScaleTransition(
                        scale: scaleAnimation,
                        child: FadeTransition(
                          opacity: fadeAnimation,
                          child: AnimatedBuilder(
                            animation: radiusAnimation,
                            builder: (context, child) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  radiusAnimation.value,
                                ),
                                child: child,
                              );
                            },
                            child: child,
                          ),
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
            _fetchReports();
          },
          backgroundColor: AppColors.brand500,
          elevation: 4,
          icon: Icon(Icons.add, color: AppColors.white, size: 22),
          label: Text(
            'Gửi báo cáo',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background with gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.appBackgroundGradient,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        'Báo cáo sự cố',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.filter_list,
                          color: AppColors.gray600,
                          size: 22,
                        ),
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
                            child: Divider(
                              height: 1,
                              color: AppColors.brand500,
                            ),
                          ),
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
                                              'urgent',
                                            )) {
                                              _selectedFilters.remove('urgent');
                                            } else {
                                              _selectedFilters.add('urgent');
                                            }
                                          });
                                          setMenuState(() {});
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'Khẩn cấp',
                                            style: TextStyle(
                                              color:
                                                  _selectedFilters.contains(
                                                    'urgent',
                                                  )
                                                  ? AppColors.brand500
                                                  : Colors.black,
                                              fontSize: 13,
                                              fontWeight:
                                                  _selectedFilters.contains(
                                                    'urgent',
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
                                            if (_selectedFilters.contains(
                                              'processing',
                                            )) {
                                              _selectedFilters.remove(
                                                'processing',
                                              );
                                            } else {
                                              _selectedFilters.add(
                                                'processing',
                                              );
                                            }
                                          });
                                          setMenuState(() {});
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'Đang xử lý',
                                            style: TextStyle(
                                              color:
                                                  _selectedFilters.contains(
                                                    'processing',
                                                  )
                                                  ? AppColors.brand500
                                                  : Colors.black,
                                              fontSize: 13,
                                              fontWeight:
                                                  _selectedFilters.contains(
                                                    'processing',
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
                                              'high',
                                            )) {
                                              _selectedFilters.remove('high');
                                            } else {
                                              _selectedFilters.add('high');
                                            }
                                          });
                                          setMenuState(() {});
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'Cao',
                                            style: TextStyle(
                                              color:
                                                  _selectedFilters.contains(
                                                    'high',
                                                  )
                                                  ? AppColors.brand500
                                                  : Colors.black,
                                              fontSize: 13,
                                              fontWeight:
                                                  _selectedFilters.contains(
                                                    'high',
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
                                            if (_selectedFilters.contains(
                                              'completed',
                                            )) {
                                              _selectedFilters.remove(
                                                'completed',
                                              );
                                            } else {
                                              _selectedFilters.add('completed');
                                            }
                                          });
                                          setMenuState(() {});
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'Đã hoàn thành',
                                            style: TextStyle(
                                              color:
                                                  _selectedFilters.contains(
                                                    'completed',
                                                  )
                                                  ? AppColors.brand500
                                                  : Colors.black,
                                              fontSize: 13,
                                              fontWeight:
                                                  _selectedFilters.contains(
                                                    'completed',
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
                                              'medium',
                                            )) {
                                              _selectedFilters.remove('medium');
                                            } else {
                                              _selectedFilters.add('medium');
                                            }
                                          });
                                          setMenuState(() {});
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'Trung bình',
                                            style: TextStyle(
                                              color:
                                                  _selectedFilters.contains(
                                                    'medium',
                                                  )
                                                  ? AppColors.brand500
                                                  : Colors.black,
                                              fontSize: 13,
                                              fontWeight:
                                                  _selectedFilters.contains(
                                                    'medium',
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
                                            if (_selectedFilters.contains(
                                              'closed',
                                            )) {
                                              _selectedFilters.remove('closed');
                                            } else {
                                              _selectedFilters.add('closed');
                                            }
                                          });
                                          setMenuState(() {});
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'Đã đóng',
                                            style: TextStyle(
                                              color:
                                                  _selectedFilters.contains(
                                                    'closed',
                                                  )
                                                  ? AppColors.brand500
                                                  : Colors.black,
                                              fontSize: 13,
                                              fontWeight:
                                                  _selectedFilters.contains(
                                                    'closed',
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
                                              'low',
                                            )) {
                                              _selectedFilters.remove('low');
                                            } else {
                                              _selectedFilters.add('low');
                                            }
                                          });
                                          setMenuState(() {});
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'Thấp',
                                            style: TextStyle(
                                              color:
                                                  _selectedFilters.contains(
                                                    'low',
                                                  )
                                                  ? AppColors.brand500
                                                  : Colors.black,
                                              fontSize: 13,
                                              fontWeight:
                                                  _selectedFilters.contains(
                                                    'low',
                                                  )
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
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo mã, tiêu đề, vị trí...',
                      hintStyle: TextStyle(
                        color: AppColors.gray400,
                        fontSize: 14,
                      ),
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
                        borderSide: BorderSide(
                          color: AppColors.brand500,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Main content - Report history list
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.brand500,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _filteredReports.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.assignment_outlined,
                                        size: 64,
                                        color: AppColors.gray300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchQuery.isNotEmpty ||
                                                _selectedFilters.isNotEmpty
                                            ? 'Không tìm thấy kết quả phù hợp.'
                                            : 'Chưa có báo cáo sự cố nào.',
                                        style: TextStyle(
                                          color: AppColors.gray500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: _filteredReports.length,
                                  itemBuilder: (context, index) {
                                    final report = _filteredReports[index];
                                    return _ReportCard(
                                      report: report,
                                      statusColor: _getStatusColor(
                                        report.status,
                                      ),
                                      priorityColor: _getPriorityColor(
                                        report.priority,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReportDetailScreen(
                                                  report: report,
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final Color statusColor;
  final Color priorityColor;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.statusColor,
    required this.priorityColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with Title, Priority and Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        report.title,
                        style: TextStyle(
                          color: AppColors.gray800,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            report.priorityLabel,
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            report.statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Reporter Name
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.reporterName ?? 'N/A',
                      style: TextStyle(
                        color: AppColors.gray700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColors.gray400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.location,
                        style: TextStyle(
                          color: AppColors.gray600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Department and Date
                Row(
                  children: [
                    if (report.department != null) ...[
                      Icon(Icons.business, size: 16, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      Text(
                        report.department!,
                        style: TextStyle(
                          color: AppColors.gray600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${report.createdDate.day}/${report.createdDate.month}/${report.createdDate.year}',
                      style: TextStyle(color: AppColors.gray600, fontSize: 13),
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
}
