import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../utils/toast_utils.dart';
import '../../models/report_model.dart';
import '../../services/incident_service.dart';
import '../../l10n/app_localizations.dart';
import 'report_detail_view_screen.dart';
import '../../components/loading_infinity.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  ReportStatus? _filterStatus;
  ReportCategory? _filterCategory;

  // Data from API
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
    return _reports.where((report) {
      final matchesSearch =
          _searchController.text.isEmpty ||
          report.id.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          report.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      final matchesStatus =
          _filterStatus == null || report.status == _filterStatus;
      final matchesCategory =
          _filterCategory == null || report.category == _filterCategory;

      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    final filteredReports = _filteredReports;

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
          AppLocalizations.of(context)!.reportHistory,
          style: TextStyle(
            color: AppColors.gray800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar and filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchByIdOrTitle,
                    hintStyle: TextStyle(
                      color: AppColors.gray400,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColors.gray400),
                    filled: true,
                    fillColor: AppColors.gray50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown<ReportStatus>(
                        value: _filterStatus,
                        hint: l10n.reportStatus,
                        items: ReportStatus.values,
                        itemLabel: (status) {
                          switch (status) {
                            case ReportStatus.pending:
                              return l10n.statusPending;
                            case ReportStatus.processing:
                              return l10n.statusProcessing;
                            case ReportStatus.completed:
                              return l10n.statusCompleted;
                            case ReportStatus.closed:
                              return l10n.statusClosed;
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown<ReportCategory>(
                        value: _filterCategory,
                        hint: 'Loại vấn đề',
                        items: ReportCategory.values,
                        itemLabel: (category) {
                          switch (category) {
                            case ReportCategory.technical:
                              return 'Kỹ thuật';
                            case ReportCategory.safety:
                              return 'An toàn';
                            case ReportCategory.quality:
                              return 'Chất lượng';
                            case ReportCategory.process:
                              return 'Quy trình';
                            case ReportCategory.personnel:
                              return 'Nhân sự';
                            case ReportCategory.other:
                              return 'Khác';
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            _filterCategory = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Report list
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingInfinity())
                : RefreshIndicator(
                    onRefresh: _fetchReports,
                    child: filteredReports.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                              ),
                              Center(
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
                                      AppLocalizations.of(context)!.noReports,
                                      style: TextStyle(
                                        color: AppColors.gray500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = filteredReports[index];
                              return _ReportCard(
                                report: report,
                                statusColor: _getStatusColor(report.status),
                                priorityColor: _getPriorityColor(
                                  report.priority,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReportDetailScreen(report: report),
                                    ),
                                  );
                                },
                                onRate:
                                    report.status == ReportStatus.completed &&
                                        report.rating == null
                                    ? () {
                                        _showRatingDialog(report);
                                      }
                                    : null,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(color: AppColors.gray500, fontSize: 14),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: AppColors.gray400),
        items: [
          DropdownMenuItem<T>(
            value: null,
            child: Text(
              AppLocalizations.of(context)!.all,
              style: TextStyle(fontSize: 14),
            ),
          ),
          ...items.map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  void _showRatingDialog(ReportModel report) {
    double rating = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.rateQuality,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              report.title,
              style: TextStyle(color: AppColors.gray600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: AppColors.orange500,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1.0;
                        });
                      },
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    '${AppLocalizations.of(context)!.yourComment} (${AppLocalizations.of(context)!.optional})',
                hintStyle: TextStyle(color: AppColors.gray400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppColors.gray600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Submit rating
              Navigator.pop(context);
              ToastUtils.showSuccess(
                AppLocalizations.of(context)!.thankYouForRating,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.send),
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
  final VoidCallback? onRate;

  const _ReportCard({
    required this.report,
    required this.statusColor,
    required this.priorityColor,
    required this.onTap,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                // Header row with ID and priority
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        report.id,
                        style: TextStyle(
                          color: AppColors.gray700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
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
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
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
                const SizedBox(height: 12),

                // Title
                Text(
                  report.title,
                  style: TextStyle(
                    color: AppColors.gray800,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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

                // Rating button or rating display
                if (onRate != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onRate,
                      icon: Icon(Icons.star_border, size: 18),
                      label: Text(l10n.rateQuality),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brand500,
                        side: BorderSide(color: AppColors.brand500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ] else if (report.rating != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, size: 18, color: AppColors.orange500),
                      const SizedBox(width: 4),
                      Text(
                        '${report.rating} / 5.0',
                        style: TextStyle(
                          color: AppColors.gray700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
