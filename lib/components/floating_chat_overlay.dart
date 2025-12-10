import 'package:flutter/material.dart';
import 'dart:async';
import '../services/gemini_service.dart';
import '../models/chat_message.dart';
import '../config/app_colors.dart';

class FloatingChatOverlay extends StatefulWidget {
  final Widget child;

  const FloatingChatOverlay({super.key, required this.child});

  @override
  State<FloatingChatOverlay> createState() => _FloatingChatOverlayState();
}

class _FloatingChatOverlayState extends State<FloatingChatOverlay>
    with TickerProviderStateMixin {
  // Position state
  Offset _buttonPosition = Offset.zero;
  bool _isDragging = false;

  // Chat state
  bool _isChatOpen = false;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Collapse state for scroll hide
  bool _isCollapsed = false;
  Timer? _scrollTimer;

  // Controllers
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final AnimationController _collapseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _collapseAnimation;

  // Service
  final GeminiService _geminiService = GeminiService.instance;

  // Button size
  static const double _buttonSize = 56.0;
  static const double _collapsedWidth = 8.0;
  static const double _collapsedEdgePadding = 15.0;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack, // Smooth close animation
    );

    // Collapse animation controller
    _collapseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _collapseAnimation = CurvedAnimation(
      parent: _collapseController,
      curve: Curves.easeInOut,
    );

    _initGemini();
  }

  void _initGemini() async {
    try {
      await _geminiService.initialize();
    } catch (e) {
      debugPrint('Failed to initialize Gemini: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize position after context is available
    if (_buttonPosition == Offset.zero) {
      final size = MediaQuery.of(context).size;
      final padding = MediaQuery.of(context).padding;
      _buttonPosition = Offset(
        size.width - _buttonSize - 16,
        size.height - _buttonSize - padding.bottom - 160,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _collapseController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  // Handle scroll notification from child to collapse button
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isChatOpen || _isDragging) return false;

    if (notification is ScrollUpdateNotification) {
      if (!_isCollapsed) {
        _collapseButton();
      }
      // Reset timer to expand after scroll stops
      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(seconds: 2), () {
        // User can tap to expand, or auto-expand after inactivity
      });
    }
    return false;
  }

  void _collapseButton() {
    if (!_isCollapsed) {
      setState(() => _isCollapsed = true);
      _collapseController.forward();
      _snapToEdgeCollapsed();
    }
  }

  void _expandButton() {
    if (_isCollapsed) {
      final size = MediaQuery.of(context).size;
      final isOnLeft = _buttonPosition.dx < size.width / 2;

      // First reverse animation, then update position smoothly
      _collapseController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isCollapsed = false;
          });
        }
      });

      // Immediately start moving to correct position for circle
      setState(() {
        if (isOnLeft) {
          _buttonPosition = Offset(8, _buttonPosition.dy);
        } else {
          _buttonPosition = Offset(
            size.width - _buttonSize - 8,
            _buttonPosition.dy,
          );
        }
      });
    }
  }

  void _snapToEdgeCollapsed() {
    final size = MediaQuery.of(context).size;
    final isOnLeft = _buttonPosition.dx < size.width / 2;

    setState(() {
      _buttonPosition = Offset(
        isOnLeft
            ? _collapsedEdgePadding
            : size.width - _collapsedWidth - _collapsedEdgePadding,
        _buttonPosition.dy,
      );
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
    if (_isCollapsed) {
      _expandButton();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    setState(() {
      _buttonPosition = Offset(
        (_buttonPosition.dx + details.delta.dx).clamp(
          0,
          size.width - _buttonSize,
        ),
        (_buttonPosition.dy + details.delta.dy).clamp(
          padding.top,
          size.height - _buttonSize - padding.bottom,
        ),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
    _snapToEdge();
  }

  void _snapToEdge() {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;

    final targetX = _buttonPosition.dx + _buttonSize / 2 < centerX
        ? 8.0
        : size.width - _buttonSize - 8;

    setState(() {
      _buttonPosition = Offset(targetX, _buttonPosition.dy);
    });
  }

  void _handleButtonTap() {
    if (_isCollapsed) {
      _expandButton();
    } else {
      _toggleChat();
    }
  }

  void _toggleChat() {
    setState(() => _isChatOpen = !_isChatOpen);
    if (_isChatOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _geminiService.sendMessage(text);
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isOnLeft = _buttonPosition.dx < size.width / 2;

    // When chat is open, prevent the underlying screen from resizing when keyboard appears
    // This improves performance by avoiding unnecessary rebuilds of the main content
    Widget mainContent = widget.child;
    if (_isChatOpen) {
      mainContent = MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: widget.child,
      );
    }

    return Material(
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main content
            mainContent,

            // Chat panel overlay (behind button)
            if (_isChatOpen) _buildChatOverlay(),

            // Floating button - hide when chat is open
            if (!_isChatOpen)
              Positioned(
                left: _isCollapsed
                    ? (isOnLeft ? _collapsedEdgePadding : null)
                    : _buttonPosition.dx,
                right: _isCollapsed
                    ? (isOnLeft ? null : _collapsedEdgePadding)
                    : null,
                top: _buttonPosition.dy,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  onTap: _handleButtonTap,
                  child: AnimatedBuilder(
                    animation: _collapseAnimation,
                    builder: (context, child) {
                      // Animation value: 0 = expanded (circle), 1 = collapsed (bar)
                      final animValue = _collapseAnimation.value;

                      // Width: circle (56) -> bar (12)
                      final width =
                          _buttonSize -
                          ((_buttonSize - _collapsedWidth) * animValue);
                      // Height stays the same
                      final height = _buttonSize;
                      // Opacity for content fade out
                      final contentOpacity = 1.0 - animValue;

                      // For circle: radius = size/2, for bar: use smaller radius
                      final circleRadius = _buttonSize / 2;
                      final barRadius = 3.0;

                      final cornerRadius =
                          circleRadius * (1 - animValue) +
                          barRadius * animValue;

                      final borderRadius = BorderRadius.circular(cornerRadius);

                      return Container(
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.brand500, AppColors.brand600],
                          ),
                          borderRadius: borderRadius,
                        ),
                        child: ClipRRect(
                          borderRadius: borderRadius,
                          child: Opacity(
                            opacity: contentOpacity.clamp(0.0, 1.0),
                            child: const Center(
                              child: Icon(
                                Icons.chat_bubble_rounded,
                                color: AppColors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatOverlay() {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Panel dimensions
    final panelWidth = 400.0.clamp(0.0, size.width - 32);
    final panelHeight = size.height * 0.6;

    // Panel position (center-bottom)
    final panelX = (size.width - panelWidth) / 2;
    final panelY = size.height - panelHeight - padding.bottom - 100;

    // Calculate transform origin based on button position
    // This makes the panel "emerge" from where the button is
    final buttonCenterX = _buttonPosition.dx + _buttonSize / 2;
    final buttonCenterY = _buttonPosition.dy + _buttonSize / 2;

    // Origin point relative to panel center
    final originX = (buttonCenterX - (panelX + panelWidth / 2)) / panelWidth;
    final originY = (buttonCenterY - (panelY + panelHeight / 2)) / panelHeight;

    return Positioned.fill(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: _toggleChat,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withOpacity(
                      0.38 * _scaleAnimation.value,
                    ),
                  );
                },
              ),
            ),
            // Chat Window - Scale animation from button position
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {},
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform(
                        alignment: FractionalOffset(
                          0.5 + originX.clamp(-0.5, 0.5),
                          0.5 + originY.clamp(-0.5, 0.5),
                        ),
                        transform: Matrix4.identity()
                          ..scale(_scaleAnimation.value),
                        child: Opacity(
                          opacity: _scaleAnimation.value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      constraints: BoxConstraints(
                        maxHeight: panelHeight,
                        maxWidth: panelWidth,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.15),
                            blurRadius: 24,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildChatHeader(),
                            Flexible(child: _buildMessageList()),
                            _buildInputArea(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.brand500, AppColors.brand600],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'AI Assistant',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: _toggleChat,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.brand500,
            ),
            SizedBox(height: 12),
            Text(
              'Xin chào! Tôi có thể giúp gì cho bạn?',
              style: TextStyle(color: AppColors.gray500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildLoadingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.brand500 : AppColors.gray100,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? AppColors.white : AppColors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const _TypingDotsAnimation(),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: AppColors.gray50),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: AppColors.black),
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: const TextStyle(color: AppColors.gray400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.brand500,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _sendMessage,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.send, color: AppColors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated typing dots widget
class _TypingDotsAnimation extends StatefulWidget {
  const _TypingDotsAnimation();

  @override
  State<_TypingDotsAnimation> createState() => _TypingDotsAnimationState();
}

class _TypingDotsAnimationState extends State<_TypingDotsAnimation>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Start staggered animation
    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        _controllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 150));
      }
      await Future.delayed(const Duration(milliseconds: 100));
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        _controllers[i].reverse();
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -4 * _animations[index].value),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.gray500.withValues(
                      alpha: 0.5 + (0.5 * _animations[index].value),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
