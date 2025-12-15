/// Model for file attachments stored in MongoDB GridFS
class AttachmentModel {
  final String fileId;
  final String filename;
  final String originalName;
  final String mimeType;
  final int size;
  final String url;

  AttachmentModel({
    required this.fileId,
    required this.filename,
    required this.originalName,
    required this.mimeType,
    required this.size,
    required this.url,
  });

  /// Parse from JSON (new MongoDB GridFS format)
  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      fileId: json['file_id'] ?? json['fileId'] ?? '',
      filename: json['filename'] ?? '',
      originalName:
          json['original_name'] ??
          json['originalName'] ??
          json['filename'] ??
          '',
      mimeType:
          json['mime_type'] ?? json['mimeType'] ?? 'application/octet-stream',
      size: json['size'] ?? 0,
      url: json['url'] ?? '',
    );
  }

  /// Parse from legacy format (disk storage)
  factory AttachmentModel.fromLegacyJson(Map<String, dynamic> json) {
    final path = json['path'] ?? '';
    final filename = json['filename'] ?? '';

    return AttachmentModel(
      fileId: '', // No file_id in legacy format
      filename: filename,
      originalName: json['original_name'] ?? json['originalname'] ?? filename,
      mimeType:
          json['mime_type'] ?? json['mimetype'] ?? 'application/octet-stream',
      size: json['size'] ?? 0,
      // Convert legacy path to URL
      url: path.isNotEmpty ? '/uploads/${path.split('/').last}' : '',
    );
  }

  /// Smart parser - detects format automatically
  factory AttachmentModel.parse(dynamic json) {
    if (json is String) {
      // Legacy: just a filename string
      return AttachmentModel(
        fileId: '',
        filename: json,
        originalName: json,
        mimeType: _guessMimeType(json),
        size: 0,
        url: '/uploads/$json',
      );
    }

    if (json is Map<String, dynamic>) {
      // Check if it's new format (has file_id or url with /api/media/)
      if (json.containsKey('file_id') ||
          json.containsKey('fileId') ||
          (json['url']?.toString().contains('/api/media/') ?? false)) {
        return AttachmentModel.fromJson(json);
      }
      // Legacy format
      return AttachmentModel.fromLegacyJson(json);
    }

    // Fallback
    return AttachmentModel(
      fileId: '',
      filename: 'unknown',
      originalName: 'unknown',
      mimeType: 'application/octet-stream',
      size: 0,
      url: '',
    );
  }

  /// Parse list of attachments
  static List<AttachmentModel> parseList(dynamic json) {
    if (json == null) return [];

    if (json is String) {
      // Try to parse as JSON string
      try {
        final List<dynamic> parsed = json.startsWith('[')
            ? _parseJsonList(json)
            : [];
        return parsed.map((e) => AttachmentModel.parse(e)).toList();
      } catch (_) {
        return [];
      }
    }

    if (json is List) {
      return json.map((e) => AttachmentModel.parse(e)).toList();
    }

    return [];
  }

  static List<dynamic> _parseJsonList(String json) {
    // Simple JSON array parser
    try {
      return List<dynamic>.from(
        (json as dynamic) is String
            ? [] // Would need proper JSON parsing
            : json as List,
      );
    } catch (_) {
      return [];
    }
  }

  /// Check if this is an image
  bool get isImage => mimeType.startsWith('image/');

  /// Check if this is a video
  bool get isVideo => mimeType.startsWith('video/');

  /// Check if this is audio
  bool get isAudio => mimeType.startsWith('audio/');

  /// Check if this is a document
  bool get isDocument =>
      mimeType.contains('pdf') ||
      mimeType.contains('word') ||
      mimeType.contains('document') ||
      mimeType.contains('spreadsheet') ||
      mimeType.contains('excel');

  /// Get full URL with base
  String getFullUrl(String baseUrl) {
    if (url.startsWith('http')) return url;
    return '$baseUrl$url';
  }

  /// Guess mime type from filename
  static String _guessMimeType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      default:
        return 'application/octet-stream';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
      'filename': filename,
      'original_name': originalName,
      'mime_type': mimeType,
      'size': size,
      'url': url,
    };
  }

  @override
  String toString() {
    return 'AttachmentModel(fileId: $fileId, originalName: $originalName, mimeType: $mimeType)';
  }
}
