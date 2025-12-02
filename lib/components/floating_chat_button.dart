import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Draggable floating chat button widget
class FloatingChatButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool hasUnreadMessages;

  const FloatingChatButton({
    super.key,
    required this.onPressed,
    this.hasUnreadMessages = false,
  });

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton>
    with SingleTickerProviderStateMixin {
  late Offset _position;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDragging = false;

  // Button size
  static const double _buttonSize = 56.0;
  static const double _padding = 16.0;

  @override
  void initState() {
    super.initState();
    // Default position (bottom right)
    _position = const Offset(
      -1,
      -1,
    ); // Will be initialized in didChangeDependencies

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize position if not set
    if (_position.dx < 0 || _position.dy < 0) {
      final size = MediaQuery.of(context).size;
      _position = Offset(
        size.width - _buttonSize - _padding,
        size.height - _buttonSize - _padding - 100, // Above bottom nav
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
    _animationController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final size = MediaQuery.of(context).size;

    setState(() {
      _position = Offset(
        (_position.dx + details.delta.dx).clamp(
          _padding,
          size.width - _buttonSize - _padding,
        ),
        (_position.dy + details.delta.dy).clamp(
          _padding,
          size.height - _buttonSize - _padding - 80,
        ),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _animationController.reverse();

    // Snap to nearest edge
    final size = MediaQuery.of(context).size;
    final centerX = _position.dx + _buttonSize / 2;

    setState(() {
      _isDragging = false;
      // Snap to left or right edge
      if (centerX < size.width / 2) {
        _position = Offset(_padding, _position.dy);
      } else {
        _position = Offset(size.width - _buttonSize - _padding, _position.dy);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTap: widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: _isDragging
                ? Duration.zero
                : const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main button
                Container(
                  width: _buttonSize,
                  height: _buttonSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [AppColors.brand500, AppColors.brand600]
                          : [AppColors.brand500, AppColors.brand600],
                    ),
                    borderRadius: BorderRadius.circular(_buttonSize / 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand500.withValues(alpha: 0.4),
                        blurRadius: _isDragging ? 16 : 12,
                        offset: const Offset(0, 4),
                        spreadRadius: _isDragging ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                // Unread indicator
                if (widget.hasUnreadMessages)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode ? Colors.grey[900]! : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
