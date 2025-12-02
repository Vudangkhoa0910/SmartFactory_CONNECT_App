import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../config/app_colors.dart';
import '../main.dart' show navigatorKey;

/// Utility class for showing toast notifications throughout the app
/// No context required - uses global navigatorKey
class ToastUtils {
  // Private constructor to prevent instantiation
  ToastUtils._();

  /// Get current context from navigatorKey
  static BuildContext? get _context => navigatorKey.currentContext;

  /// Show success toast
  static void showSuccess(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (_context == null) return;
    toastification.show(
      context: _context!,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: title != null
          ? Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      description: Text(message, style: const TextStyle(color: Colors.white)),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      primaryColor: Colors.white,
      backgroundColor: AppColors.success500,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.success500.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.none,
      closeOnClick: true,
      pauseOnHover: false,
      dragToClose: true,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Show error toast
  static void showError(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    if (_context == null) return;
    toastification.show(
      context: _context!,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: title != null
          ? Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      description: Text(message, style: const TextStyle(color: Colors.white)),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      primaryColor: Colors.white,
      backgroundColor: AppColors.error500,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.error500.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.none,
      closeOnClick: true,
      pauseOnHover: false,
      dragToClose: true,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// Show warning toast
  static void showWarning(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (_context == null) return;
    toastification.show(
      context: _context!,
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      title: title != null
          ? Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      description: Text(message, style: const TextStyle(color: Colors.white)),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      primaryColor: Colors.white,
      backgroundColor: AppColors.orange500,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.orange500.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.none,
      closeOnClick: true,
      pauseOnHover: false,
      dragToClose: true,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  /// Show info toast
  static void showInfo(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (_context == null) return;
    toastification.show(
      context: _context!,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: title != null
          ? Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      description: Text(message, style: const TextStyle(color: Colors.white)),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      primaryColor: Colors.white,
      backgroundColor: AppColors.blueLight500,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.blueLight500.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.none,
      closeOnClick: true,
      pauseOnHover: false,
      dragToClose: true,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  /// Show loading toast (doesn't auto dismiss)
  static ToastificationItem? showLoading(String message, {String? title}) {
    if (_context == null) return null;
    return toastification.show(
      context: _context!,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: title != null
          ? Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      description: Text(message, style: const TextStyle(color: Colors.white)),
      alignment: Alignment.topCenter,
      autoCloseDuration: null, // Don't auto close
      primaryColor: Colors.white,
      backgroundColor: AppColors.brand500,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      icon: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.none,
      closeOnClick: false,
      pauseOnHover: false,
      dragToClose: false,
    );
  }

  /// Dismiss a specific toast
  static void dismiss(ToastificationItem item) {
    toastification.dismiss(item);
  }

  /// Dismiss all toasts
  static void dismissAll() {
    toastification.dismissAll();
  }
}
