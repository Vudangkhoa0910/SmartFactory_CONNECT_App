import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/idea_box_model.dart';
import 'create_idea_screen.dart';
import 'idea_detail_screen.dart';

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
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock data - Trong thực tế sẽ lấy từ API
  List<IdeaBoxItem> _getMockData(IdeaBoxType type) {
    // Hòm trắng: Hiển thị TẤT CẢ góp ý công khai (ai cũng xem được)
    // Hòm hồng: Chỉ hiển thị góp ý ẩn danh của NGƯỜI DÙNG HIỆN TẠI
    
    if (type == IdeaBoxType.white) {
      // Hòm trắng - Tất cả góp ý công khai
      return [
        IdeaBoxItem(
          id: '1',
          boxType: IdeaBoxType.white,
          issueType: IssueType.quality,
          title: 'Cải tiến quy trình kiểm tra chất lượng',
          content: 'Đề xuất sử dụng máy quét tự động để tăng độ chính xác...',
          attachments: [],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          status: IdeaStatus.underReview,
          difficultyLevel: DifficultyLevel.medium,
          senderName: 'Nguyễn Văn A',
          senderEmployeeId: 'NV001',
          senderDepartment: 'Sản xuất 1',
          processLogs: [],
          currentHandlerName: 'Nguyễn Thị B',
          currentHandlerRole: 'Supervisor',
        ),
        IdeaBoxItem(
          id: '2',
          boxType: IdeaBoxType.white,
          issueType: IssueType.safety,
          title: 'Tăng cường biện pháp an toàn tại khu vực A',
          content: 'Cần lắp đặt thêm biển báo và rào chắn...',
          attachments: [],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          status: IdeaStatus.approved,
          difficultyLevel: DifficultyLevel.easy,
          senderName: 'Trần Văn C',
          senderEmployeeId: 'NV002',
          senderDepartment: 'An toàn',
          processLogs: [],
          currentHandlerName: 'Lê Văn D',
          currentHandlerRole: 'Manager',
        ),
        IdeaBoxItem(
          id: '3',
          boxType: IdeaBoxType.white,
          issueType: IssueType.process,
          title: 'Cải thiện quy trình vận chuyển nguyên liệu',
          content: 'Đề xuất sử dụng xe nâng tự động để tăng hiệu suất...',
          attachments: [],
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          status: IdeaStatus.completed,
          difficultyLevel: DifficultyLevel.hard,
          senderName: 'Lê Thị E',
          senderEmployeeId: 'NV003',
          senderDepartment: 'Kho vận',
          processLogs: [],
        ),
      ];
    } else {
      // Hòm hồng - Chỉ góp ý ẩn danh của người dùng hiện tại
      // TODO: Trong thực tế sẽ filter theo userId từ API
      return [
        IdeaBoxItem(
          id: '101',
          boxType: IdeaBoxType.pink,
          issueType: IssueType.welfare,
          title: 'Góp ý về chế độ phúc lợi',
          content: 'Đề xuất tăng thêm ngày nghỉ phép hàng năm...',
          attachments: [],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          status: IdeaStatus.underReview,
          senderName: null, // Ẩn danh
          senderEmployeeId: null,
          senderDepartment: null,
          processLogs: [],
          currentHandlerName: 'Admin HR',
          currentHandlerRole: 'Admin',
        ),
        IdeaBoxItem(
          id: '102',
          boxType: IdeaBoxType.pink,
          issueType: IssueType.workEnvironment,
          title: 'Cải thiện điều kiện làm việc',
          content: 'Cần lắp đặt thêm quạt làm mát tại khu vực sản xuất...',
          attachments: [],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          status: IdeaStatus.completed,
          senderName: null, // Ẩn danh
          senderEmployeeId: null,
          senderDepartment: null,
          processLogs: [],
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              _buildFilterBar(),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand500.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.mail_outline,
              color: AppColors.brand500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hòm thư góp ý',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  'Chia sẻ ý kiến của bạn',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {
                // TODO: Thêm chức năng tìm kiếm
              },
              icon: const Icon(Icons.search),
              color: AppColors.gray600,
              iconSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand500.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              AppColors.brand500,
              AppColors.brand400,
            ],
          ),
        ),
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.gray600,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 18),
                const SizedBox(width: 6),
                const Text('Hòm trắng'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 18),
                const SizedBox(width: 6),
                const Text('Hòm hồng'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip('Tất cả', 'all'),
          _buildFilterChip('Đang xem xét', 'review'),
          _buildFilterChip('Đã phê duyệt', 'approved'),
          _buildFilterChip('Hoàn thành', 'completed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: AppColors.white,
        selectedColor: AppColors.brand50,
        checkmarkColor: AppColors.brand600,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.brand600 : AppColors.gray600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.brand500 : AppColors.gray200,
          width: isSelected ? 1.5 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildIdeaList(IdeaBoxType type) {
    final ideas = _getMockData(type);
    
    if (ideas.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120), // Bottom padding để tránh bottom nav
      itemCount: ideas.length,
      itemBuilder: (context, index) {
        return _buildIdeaCard(ideas[index]);
      },
    );
  }

  Widget _buildEmptyState(IdeaBoxType type) {
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
            type == IdeaBoxType.white
                ? 'Chưa có góp ý trong hòm trắng'
                : 'Bạn chưa gửi góp ý ẩn danh nào',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            type == IdeaBoxType.white
                ? 'Hãy là người đầu tiên chia sẻ ý kiến!'
                : 'Gửi góp ý ẩn danh để bảo vệ thông tin của bạn',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(IdeaBoxItem idea) {
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
                    if (idea.senderName != null) ...[
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
                          'Ẩn danh',
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 80), // Đẩy lên khỏi bottom nav
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateIdeaScreen(
                initialBoxType: _tabController.index == 0
                    ? IdeaBoxType.white
                    : IdeaBoxType.pink,
              ),
            ),
          );
        },
        backgroundColor: AppColors.brand500,
        elevation: 4,
        icon: const Icon(Icons.add, color: AppColors.white, size: 22),
        label: const Text(
          'Gửi góp ý',
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
