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
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_context == null) return;
    toastification.show(
      context: _context!,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: title != null ? Text(title) : null,
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      primaryColor: AppColors.success500,
      backgroundColor: AppColors.success500,
      foregroundColor: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.success500.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  /// Show error toast
  static void showError(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (_context == null) return;
    toastification.show(
      context: _context!,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: title != null ? Text(title) : null,
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      primaryColor: AppColors.error500,
      backgroundColor: AppColors.error500,
      foregroundColor: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.error500.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.always,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  /// Show warning toast
  static void showWarning(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_context == null) return;
    toastification.show(
      context: _context!,
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      title: title != null ? Text(title) : null,
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      primaryColor: AppColors.orange500,
      backgroundColor: AppColors.orange500,
      foregroundColor: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.orange500.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  /// Show info toast
  static void showInfo(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_context == null) return;
    toastification.show(
      context: _context!,
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      title: title != null ? Text(title) : null,
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      primaryColor: AppColors.blueLight500,
      backgroundColor: AppColors.blueLight500,
      foregroundColor: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.blueLight500.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  /// Show loading toast (doesn't auto dismiss)
  static ToastificationItem? showLoading(String message, {String? title}) {
    if (_context == null) return null;
    return toastification.show(
      context: _context!,
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      title: title != null ? Text(title) : null,
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: null, // Don't auto close
      primaryColor: AppColors.brand500,
      backgroundColor: AppColors.brand500,
      foregroundColor: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      icon: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.white,
        ),
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
