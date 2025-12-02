/// Chat message model for Gemini chatbot
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  /// Create a user message
  factory ChatMessage.user(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
  }

  /// Create a bot message
  factory ChatMessage.bot(
    String text, {
    MessageStatus status = MessageStatus.sent,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      status: status,
    );
  }

  /// Create a loading message (bot is typing)
  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.loading,
    );
  }

  /// Copy with new values
  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Message status enum
enum MessageStatus { sending, sent, loading, error }
