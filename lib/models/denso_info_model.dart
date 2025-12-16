class DensoInfoModel {
  final String id;
  final String type;
  final DensoPreviewInfo previewInfo;
  final Map<String, dynamic> detailContent;

  DensoInfoModel({
    required this.id,
    required this.type,
    required this.previewInfo,
    required this.detailContent,
  });

  factory DensoInfoModel.fromJson(Map<String, dynamic> json) {
    return DensoInfoModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      previewInfo: DensoPreviewInfo.fromJson(json['preview_info'] ?? {}),
      detailContent: json['detail_content'] ?? {},
    );
  }
}

class DensoPreviewInfo {
  final String category;
  final String title;
  final String subtitle;
  final String shortDesc;
  final String imageUrl;
  final String themeColor;

  DensoPreviewInfo({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.shortDesc,
    required this.imageUrl,
    required this.themeColor,
  });

  factory DensoPreviewInfo.fromJson(Map<String, dynamic> json) {
    return DensoPreviewInfo(
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      shortDesc: json['short_desc'] ?? '',
      imageUrl: json['image_url'] ?? '',
      themeColor: json['theme_color'] ?? '#000000',
    );
  }
}
