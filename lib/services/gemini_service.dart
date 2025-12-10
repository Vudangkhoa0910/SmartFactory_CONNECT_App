import 'dart:convert';
import 'api_service.dart';
import '../models/chat_message.dart';

/// Service class for AI Chat via Backend API
/// Replaces direct Gemini SDK calls with backend proxy for security and consistency
class GeminiService {
  static GeminiService? _instance;
  bool _isInitialized = false;
  
  /// Chat history for conversation context
  final List<Map<String, dynamic>> _chatHistory = [];

  GeminiService._();

  /// Get singleton instance
  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize AI service (check backend connection)
  Future<bool> initialize() async {
    try {
      // Check if backend is reachable
      final healthCheck = await ApiService.pingHealth();
      
      if (healthCheck['success'] == true) {
        _isInitialized = true;
        _chatHistory.clear();
        return true;
      } else {
        throw Exception('Backend server is not reachable');
      }
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Send message and get response from backend AI
  Future<String> sendMessage(String message) async {
    if (!_isInitialized) {
      throw Exception('AI service is not initialized');
    }

    try {
      // Build chat history for context
      final contents = _buildContents(message);
      
      // Call backend API
      final response = await ApiService.post('/api/chat/message', {
        'contents': contents,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['text'] != null) {
          final responseText = data['text'] as String;
          
          // Add to history
          _chatHistory.add({
            'role': 'user',
            'parts': [{'text': message}]
          });
          _chatHistory.add({
            'role': 'model',
            'parts': [{'text': responseText}]
          });
          
          return responseText;
        } else {
          throw Exception(data['message'] ?? 'Unknown error from AI service');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to connect to AI service');
      }
    } catch (e) {
      throw Exception('AI API error: $e');
    }
  }

  /// Build contents array with system instruction and history
  List<Map<String, dynamic>> _buildContents(String newMessage) {
    final contents = <Map<String, dynamic>>[];
    
    // Add system instruction (same as web frontend)
    contents.add({
      'role': 'user',
      'parts': [{'text': _systemPrompt}]
    });
    contents.add({
      'role': 'model',
      'parts': [{'text': 'Understood. I am ready to assist users with SmartFactory CONNECT.'}]
    });
    
    // Add chat history
    contents.addAll(_chatHistory);
    
    // Add new message
    contents.add({
      'role': 'user',
      'parts': [{'text': newMessage}]
    });
    
    return contents;
  }

  /// Stream response for real-time updates (falls back to regular call)
  Stream<String> streamMessage(String message) async* {
    // Backend doesn't support streaming yet, use regular call
    final response = await sendMessage(message);
    yield response;
  }

  /// Reset chat session
  void resetChat() {
    _chatHistory.clear();
  }

  /// Get chat history as ChatMessage list
  List<ChatMessage> getChatHistory() {
    final history = <ChatMessage>[];
    
    for (final content in _chatHistory) {
      final isUser = content['role'] == 'user';
      final parts = content['parts'] as List;
      final text = parts.isNotEmpty ? parts[0]['text'] as String : '';
      
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
    _chatHistory.clear();
    _isInitialized = false;
  }

  /// System prompt for the chatbot (same as web frontend)
  static const String _systemPrompt = '''Bạn là trợ lý AI thông minh của ứng dụng SmartFactory CONNECT - một ứng dụng quản lý nhà máy thông minh.

Vai trò của bạn:
- Hỗ trợ người dùng trong việc sử dụng ứng dụng
- Trả lời câu hỏi về quy trình nhà máy
- Hướng dẫn báo cáo sự cố và đề xuất ý tưởng cải tiến
- Cung cấp thông tin về các tính năng của ứng dụng

Các tính năng chính của ứng dụng Mobile:
1. Báo cáo sự cố (Incident Report) - Tab "Báo cáo"
2. Đề xuất ý tưởng cải tiến (Ideas) - Tab "Hòm thư"
3. Tin tức nhà máy (News) - Tab "Tin tức"
4. Quản lý hồ sơ cá nhân (Profile) - Tab "Hồ sơ"
5. Thông báo (Notifications)
6. Trợ lý AI (Chat)

Nguyên tắc:
- Trả lời ngắn gọn, rõ ràng và chuyên nghiệp
- Sử dụng tiếng Việt làm ngôn ngữ chính
- Luôn thân thiện và hữu ích
- Nếu không biết câu trả lời, hãy thành thật và gợi ý cách tìm thông tin

Lưu ý: Đây là ứng dụng Mobile, một số tính năng như tìm kiếm sự cố nâng cao chỉ có trên Web.''';
}
