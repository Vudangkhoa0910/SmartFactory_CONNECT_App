class NewsModel {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String date;
  final String author;
  final String category;
  final bool isPriority;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.date,
    this.author = 'DENSO',
    this.category = 'company_announcement',
    this.isPriority = false,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // Format date - use ISO format, let UI handle locale-specific formatting
    String formattedDate = '';
    if (json['created_at'] != null) {
      try {
        final DateTime dt = DateTime.parse(json['created_at']);
        // Store as ISO string, UI will format with locale
        formattedDate = dt.toIso8601String();
      } catch (e) {
        formattedDate = json['created_at'].toString();
      }
    }

    // Extract image from attachments if available
    String imgUrl = '';
    if (json['attachments'] != null) {
      final List attachments = json['attachments'];
      if (attachments.isNotEmpty) {
        // Check for image mime type
        final imageAttachment = attachments.firstWhere(
          (att) => att['mime_type'].toString().startsWith('image/'),
          orElse: () => null,
        );
        if (imageAttachment != null) {
          // Construct full URL if needed, or just path
          // For now, we might need to handle this in UI or Service to prepend base URL
          // Assuming the path is relative like 'uploads/news/...'
          imgUrl = imageAttachment['path'] ?? '';
        }
      }
    }

    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['excerpt'] ?? '',
      content: json['content'] ?? '',
      imageUrl: imgUrl,
      date: formattedDate,
      author: json['author_name'] ?? 'DENSO',
      category: json['category'] ?? 'company_announcement',
      isPriority: json['is_priority'] ?? false,
    );
  }

  // Sample data for testing
  static List<NewsModel> getSampleNews() {
    return [
      NewsModel(
        id: '1',
        title: 'Chương trình đào tạo kỹ năng an toàn lao động',
        description:
            'Công ty tổ chức chương trình đào tạo toàn diện về an toàn lao động cho toàn bộ nhân viên.',
        content: '''
# Chương trình đào tạo kỹ năng an toàn lao động

Công ty DENSO tự hào thông báo về chương trình đào tạo toàn diện về an toàn lao động dành cho toàn bộ nhân viên.

## Thông tin chi tiết

Chương trình đào tạo được thiết kế nhằm nâng cao nhận thức và kỹ năng về an toàn lao động cho mọi cấp bậc trong công ty. Các chủ đề chính bao gồm:

- Nhận diện và phòng ngừa rủi ro trong môi trường làm việc
- Quy trình xử lý sự cố và ứng phó khẩn cấp
- Sử dụng thiết bị bảo hộ lao động đúng cách
- Tuân thủ các quy định an toàn tại nơi làm việc

## Lợi ích

Việc tham gia chương trình sẽ giúp nhân viên:
- Nâng cao ý thức về an toàn cá nhân và đồng nghiệp
- Giảm thiểu tai nạn lao động
- Tạo môi trường làm việc an toàn và chuyên nghiệp

Mọi nhân viên đều được khuyến khích tham gia đầy đủ để đảm bảo an toàn tối đa tại nơi làm việc.
''',
        imageUrl: '',
        date: '15 Tháng 11, 2025',
        author: 'Phòng Nhân sự',
        category: 'safety_alert',
        isPriority: true,
      ),
      NewsModel(
        id: '2',
        title: 'Cập nhật hệ thống quản lý sản xuất mới',
        description:
            'Hệ thống quản lý sản xuất SmartFactory CONNECT chính thức ra mắt với nhiều tính năng mới.',
        content: '''
# Hệ thống SmartFactory CONNECT chính thức ra mắt

Chúng tôi vui mừng thông báo về việc triển khai hệ thống quản lý sản xuất SmartFactory CONNECT với nhiều tính năng hiện đại.

## Tính năng nổi bật

- Quản lý báo cáo sự cố real-time
- Hệ thống thông báo tức thì
- Dashboard theo dõi tiến độ
- Tích hợp với các hệ thống hiện có

## Lợi ích

Hệ thống mới giúp:
- Tăng hiệu quả quản lý
- Giảm thời gian xử lý sự cố
- Cải thiện giao tiếp nội bộ
- Theo dõi KPI chính xác

Toàn bộ nhân viên sẽ được đào tạo về cách sử dụng hệ thống trong tuần tới.
''',
        imageUrl: '',
        date: '12 Tháng 11, 2025',
        author: 'Phòng IT',
        category: 'production_update',
        isPriority: false,
      ),
      NewsModel(
        id: '3',
        title: 'Thông báo nghỉ lễ Tết Nguyên Đán 2026',
        description:
            'Công ty thông báo lịch nghỉ Tết Nguyên Đán và kế hoạch làm việc sau kỳ nghỉ.',
        content: '''
# Thông báo nghỉ lễ Tết Nguyên Đán 2026

## Lịch nghỉ

Công ty thông báo lịch nghỉ Tết Nguyên Đán 2026 như sau:

- Bắt đầu: 26/01/2026 (28 Tết)
- Kết thúc: 02/02/2026 (Mùng 6 Tết)
- Trở lại làm việc: 03/02/2026 (Thứ Hai)

## Lưu ý quan trọng

- Hoàn thành công việc trước kỳ nghỉ
- Bàn giao công việc rõ ràng
- Tắt thiết bị điện không cần thiết
- Kiểm tra an ninh khu vực làm việc

Chúc toàn thể cán bộ nhân viên một kỳ nghỉ Tết vui vẻ, an lành và đoàn viên!
''',
        imageUrl: '',
        date: '10 Tháng 11, 2025',
        author: 'Ban Giám đốc',
        category: 'company_announcement',
        isPriority: true,
      ),
    ];
  }
}
