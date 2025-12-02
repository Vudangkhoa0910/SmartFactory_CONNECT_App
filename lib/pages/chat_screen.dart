import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

/// Chat screen with Gemini AI integration
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _initError;

  late AnimationController _sendButtonAnimationController;
  late Animation<double> _sendButtonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeGemini();

    _sendButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _sendButtonScaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _sendButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeGemini() async {
    try {
      await GeminiService.instance.initialize();
      setState(() {
        _isInitialized = true;
        _initError = null;
      });

      // Add welcome message
      _addWelcomeMessage();
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _initError = e.toString();
      });
    }
  }

  void _addWelcomeMessage() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _messages.add(ChatMessage.bot(l10n.aiWelcomeMessage));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sendButtonAnimationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Add user message
    setState(() {
      _messages.add(ChatMessage.user(text));
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    // Add loading indicator
    final loadingMessage = ChatMessage.loading();
    setState(() {
      _messages.add(loadingMessage);
    });
    _scrollToBottom();

    try {
      final response = await GeminiService.instance.sendMessage(text);

      setState(() {
        // Remove loading message
        _messages.removeWhere((m) => m.status == MessageStatus.loading);
        // Add bot response
        _messages.add(ChatMessage.bot(response));
        _isLoading = false;
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        // Remove loading message
        _messages.removeWhere((m) => m.status == MessageStatus.loading);
        // Add error message
        _messages.add(
          ChatMessage.bot(
            '${l10n.aiErrorMessage}\n\n${l10n.error}: ${e.toString()}',
            status: MessageStatus.error,
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _resetChat() {
    HapticFeedback.mediumImpact();
    GeminiService.instance.resetChat();
    setState(() {
      _messages.clear();
    });
    _addWelcomeMessage();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.gray900 : Colors.grey[50],
      appBar: _buildAppBar(isDarkMode),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages
            Expanded(child: _buildMessageList(isDarkMode)),

            // Input area
            _buildInputArea(isDarkMode),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: isDarkMode ? AppColors.gray800 : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDarkMode ? Colors.white : AppColors.gray800,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.brand500, AppColors.brand600],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aiAssistant,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.gray800,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _isInitialized ? 'Online' : l10n.loading,
                style: TextStyle(
                  color: _isInitialized
                      ? Colors.green
                      : (isDarkMode ? Colors.grey : Colors.grey[600]),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: isDarkMode ? Colors.white70 : AppColors.gray600,
          ),
          onPressed: _resetChat,
          tooltip: l10n.clearChat,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessageList(bool isDarkMode) {
    final l10n = AppLocalizations.of(context)!;
    if (_initError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.brand500,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.aiErrorMessage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.gray800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white60 : AppColors.gray600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeGemini,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: isDarkMode ? Colors.white30 : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.startConversation,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white60 : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _MessageBubble(message: message, isDarkMode: isDarkMode);
      },
    );
  }

  Widget _buildInputArea(bool isDarkMode) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gray800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.gray700 : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.gray800,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: l10n.typeMessage,
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white38 : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send button
          GestureDetector(
            onTapDown: (_) => _sendButtonAnimationController.forward(),
            onTapUp: (_) {
              _sendButtonAnimationController.reverse();
              _sendMessage();
            },
            onTapCancel: () => _sendButtonAnimationController.reverse(),
            child: ScaleTransition(
              scale: _sendButtonScaleAnimation,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isLoading
                        ? [Colors.grey, Colors.grey[600]!]
                        : [AppColors.brand500, AppColors.brand600],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.brand500.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Icon(
                  _isLoading ? Icons.hourglass_top_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDarkMode;

  const _MessageBubble({required this.message, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    if (message.status == MessageStatus.loading) {
      return _buildLoadingBubble();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: message.isUser ? 48 : 0,
        right: message.isUser ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.brand500, AppColors.brand600],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.brand500
                    : (isDarkMode ? AppColors.gray700 : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: message.isUser
                    ? null
                    : Border.all(
                        color: isDarkMode
                            ? Colors.transparent
                            : Colors.grey[200]!,
                        width: 1,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : (isDarkMode ? Colors.white : AppColors.gray800),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  if (message.status == MessageStatus.error) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 14,
                          color: Colors.red[300],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lỗi gửi tin nhắn',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[300],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.brand500, AppColors.brand600],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.gray700 : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: isDarkMode ? Colors.transparent : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: _TypingIndicator(isDarkMode: isDarkMode),
          ),
        ],
      ),
    );
  }
}

/// Typing indicator animation
class _TypingIndicator extends StatefulWidget {
  final bool isDarkMode;

  const _TypingIndicator({required this.isDarkMode});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = (_controller.value + delay) % 1.0;
            final scale = 0.5 + 0.5 * (1.0 - (animValue - 0.5).abs() * 2);

            return Padding(
              padding: EdgeInsets.only(right: index < 2 ? 4 : 0),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? Colors.white54
                        : AppColors.gray400,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
