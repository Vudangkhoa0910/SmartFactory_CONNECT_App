import 'dart:ui';

/// Color utility extensions and helpers
/// Provides non-deprecated alternatives to withOpacity

extension ColorUtils on Color {
  /// Creates a new color with the given alpha value (0.0 to 1.0)
  /// Use instead of deprecated withOpacity()
  Color withOpacityValue(double opacity) {
    return withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
  }
}

/// Pre-defined opacity colors for common use cases
/// Use these to avoid repeated withOpacity calls
class OpacityColors {
  // Black with various opacity levels
  static Color black03 = const Color(0xFF000000).withAlpha(8);   // 0.03
  static Color black05 = const Color(0xFF000000).withAlpha(13);  // 0.05
  static Color black10 = const Color(0xFF000000).withAlpha(26);  // 0.1
  static Color black15 = const Color(0xFF000000).withAlpha(38);  // 0.15
  static Color black30 = const Color(0xFF000000).withAlpha(77);  // 0.3
  static Color black38 = const Color(0xFF000000).withAlpha(97);  // 0.38
  static Color black50 = const Color(0xFF000000).withAlpha(128); // 0.5
  static Color black70 = const Color(0xFF000000).withAlpha(179); // 0.7
}
