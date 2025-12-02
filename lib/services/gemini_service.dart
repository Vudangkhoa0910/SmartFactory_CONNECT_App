import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env_config.dart';
import '../models/chat_message.dart';

/// Service class for Gemini AI API integration
class GeminiService {
  static GeminiService? _instance;
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;
  final EnvConfig _envConfig = EnvConfig();

  GeminiService._();

  /// Get singleton instance
  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize Gemini service with API key
  Future<bool> initialize() async {
    try {
      // Load env config first
      await _envConfig.load();

      final apiKey = _envConfig.geminiApiKey;

      if (apiKey.isEmpty) {
        throw Exception('Gemini API key is not configured');
      }

      final modelName = _envConfig.geminiModel;
      final now = DateTime.now();
      final formattedDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      _model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.5,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        systemInstruction: Content.text('''$_systemPrompt

Current Date and Time: $formattedDate
'''),
      );

      _chatSession = _model!.startChat();
      _isInitialized = true;

      return true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Send message and get response
  Future<String> sendMessage(String message) async {
    if (!_isInitialized || _chatSession == null) {
      throw Exception('Gemini service is not initialized');
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(message));

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      return text;
    } catch (e) {
      throw Exception('Gemini API error: $e');
    }
  }

  /// Stream response for real-time updates
  Stream<String> streamMessage(String message) async* {
    if (!_isInitialized || _model == null) {
      throw Exception('Gemini service is not initialized');
    }

    try {
      final response = _model!.generateContentStream([Content.text(message)]);

      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } catch (e) {
      throw Exception('Gemini API error: $e');
    }
  }

  /// Reset chat session
  void resetChat() {
    if (_model != null) {
      _chatSession = _model!.startChat();
    }
  }

  /// Get chat history
  List<ChatMessage> getChatHistory() {
    if (_chatSession == null) return [];

    final history = <ChatMessage>[];
    for (final content in _chatSession!.history) {
      final isUser = content.role == 'user';
      final textParts = <String>[];
      for (final part in content.parts) {
        if (part is TextPart) {
          textParts.add(part.text);
        }
      }
      final text = textParts.join();

      if (text.isNotEmpty) {
        history.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: text,
            isUser: isUser,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    return history;
  }

  /// Dispose resources
  void dispose() {
    _chatSession = null;
    _model = null;
    _isInitialized = false;
  }

  /// System prompt for the chatbot
  static const String _systemPrompt = '''
Bạn là trợ lý AI thông minh của ứng dụng SmartFactory CONNECT - một ứng dụng quản lý nhà máy thông minh.

Vai trò của bạn:
- Hỗ trợ người dùng trong việc sử dụng ứng dụng
- Trả lời câu hỏi về quy trình nhà máy
- Hướng dẫn báo cáo sự cố và đề xuất ý tưởng cải tiến
- Cung cấp thông tin về các tính năng của ứng dụng

Nguyên tắc:
- Trả lời ngắn gọn, rõ ràng và chuyên nghiệp
- Sử dụng ngôn ngữ phù hợp với ngữ cảnh (Tiếng Việt hoặc tiếng nước ngoài theo yêu cầu)
- Luôn thân thiện và hữu ích
- Nếu không biết câu trả lời, hãy thành thật và gợi ý cách tìm thông tin

Các tính năng chính của ứng dụng:
1. Báo cáo sự cố (Incident Report)
2. Đề xuất ý tưởng cải tiến (Kaizen Ideas)
3. Tin tức nhà máy (Factory News)
4. Quản lý hồ sơ cá nhân (Profile)
5. Thông báo (Notifications)
''';
}
