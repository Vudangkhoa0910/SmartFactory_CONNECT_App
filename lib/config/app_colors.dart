import 'package:flutter/material.dart';

/// Cấu hình màu sắc cho ứng dụng SmartFactory Connect
/// Dựa trên Tailwind CSS theme từ index.css
class AppColors {
  AppColors._();

  // ============================================================================
  // CƠ BẢN (Basic Colors)
  // ============================================================================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ============================================================================
  // MÀU THƯƠNG HIỆU (Brand Colors) - Đỏ
  // ============================================================================
  static const Color brand25 = Color(0xFFFEF2F2);
  static const Color brand50 = Color(0xFFFEE2E2);
  static const Color brand100 = Color(0xFFFECACA);
  static const Color brand200 = Color(0xFFFCA5A5);
  static const Color brand300 = Color(0xFFF87171);
  static const Color brand400 = Color(0xFFEF4444);
  static const Color brand500 = Color(0xFFDC2626); // Màu chính
  static const Color brand600 = Color(0xFFB91C1C);
  static const Color brand700 = Color(0xFF991B1B);
  static const Color brand800 = Color(0xFF7F1D1D);
  static const Color brand900 = Color(0xFF5C0F0F);
  static const Color brand950 = Color(0xFF450A0A);

  // ============================================================================
  // MÀU XÁM (Gray Colors)
  // ============================================================================
  static const Color gray25 = Color(0xFFFAFAFA);
  static const Color gray50 = Color(0xFFF5F5F5);
  static const Color gray100 = Color(0xFFE5E5E5);
  static const Color gray200 = Color(0xFFD4D4D4);
  static const Color gray300 = Color(0xFFA3A3A3);
  static const Color gray400 = Color(0xFF737373);
  static const Color gray500 = Color(0xFF525252);
  static const Color gray600 = Color(0xFF404040);
  static const Color gray700 = Color(0xFF262626);
  static const Color gray800 = Color(0xFF171717);
  static const Color gray900 = Color(0xFF0A0A0A);
  static const Color gray950 = Color(0xFF050505);
  static const Color grayDark = Color(0xFF0D0D0D);

  // ============================================================================
  // MÀU XANH DƯƠNG SÁNG (Blue Light Colors)
  // ============================================================================
  static const Color blueLight25 = Color(0xFFF5FBFF);
  static const Color blueLight50 = Color(0xFFF0F9FF);
  static const Color blueLight100 = Color(0xFFE0F2FE);
  static const Color blueLight200 = Color(0xFFB9E6FE);
  static const Color blueLight300 = Color(0xFF7CD4FD);
  static const Color blueLight400 = Color(0xFF36BFFA);
  static const Color blueLight500 = Color(0xFF0BA5EC);
  static const Color blueLight600 = Color(0xFF0086C9);
  static const Color blueLight700 = Color(0xFF026AA2);
  static const Color blueLight800 = Color(0xFF065986);
  static const Color blueLight900 = Color(0xFF0B4A6F);
  static const Color blueLight950 = Color(0xFF062C41);

  // ============================================================================
  // MÀU CAM (Orange Colors)
  // ============================================================================
  static const Color orange25 = Color(0xFFFFFAF5);
  static const Color orange50 = Color(0xFFFFF6ED);
  static const Color orange100 = Color(0xFFFFEAD5);
  static const Color orange200 = Color(0xFFFDDCAB);
  static const Color orange300 = Color(0xFFFEB273);
  static const Color orange400 = Color(0xFFFD853A);
  static const Color orange500 = Color(0xFFFB6514);
  static const Color orange600 = Color(0xFFEC4A0A);
  static const Color orange700 = Color(0xFFC4320A);
  static const Color orange800 = Color(0xFF9C2A10);
  static const Color orange900 = Color(0xFF7E2410);
  static const Color orange950 = Color(0xFF511C10);

  // ============================================================================
  // MÀU THÀNH CÔNG (Success Colors) - Xanh lá
  // ============================================================================
  static const Color success25 = Color(0xFFF6FEF9);
  static const Color success50 = Color(0xFFECFDF3);
  static const Color success100 = Color(0xFFD1FADF);
  static const Color success200 = Color(0xFFA6F4C5);
  static const Color success300 = Color(0xFF6CE9A6);
  static const Color success400 = Color(0xFF32D583);
  static const Color success500 = Color(0xFF12B76A);
  static const Color success600 = Color(0xFF039855);
  static const Color success700 = Color(0xFF027A48);
  static const Color success800 = Color(0xFF05603A);
  static const Color success900 = Color(0xFF054F31);
  static const Color success950 = Color(0xFF053321);

  // ============================================================================
  // MÀU LỖI (Error Colors) - Đỏ
  // ============================================================================
  static const Color error25 = Color(0xFFFFFBFA);
  static const Color error50 = Color(0xFFFEF3F2);
  static const Color error100 = Color(0xFFFEE4E2);
  static const Color error200 = Color(0xFFFECDCA);
  static const Color error300 = Color(0xFFFDA29B);
  static const Color error400 = Color(0xFFF97066);
  static const Color error500 = Color(0xFFF04438);
  static const Color error600 = Color(0xFFD92D20);
  static const Color error700 = Color(0xFFB42318);
  static const Color error800 = Color(0xFF912018);
  static const Color error900 = Color(0xFF7A271A);
  static const Color error950 = Color(0xFF55160C);

  // ============================================================================
  // MÀU CẢNH BÁO (Warning Colors) - Vàng
  // ============================================================================
  static const Color warning25 = Color(0xFFFFFCF5);
  static const Color warning50 = Color(0xFFFFFAEB);
  static const Color warning100 = Color(0xFFFEF0C7);
  static const Color warning200 = Color(0xFFFEDF89);
  static const Color warning300 = Color(0xFFFEC84B);
  static const Color warning400 = Color(0xFFFDB022);
  static const Color warning500 = Color(0xFFF79009);
  static const Color warning600 = Color(0xFFDC6803);
  static const Color warning700 = Color(0xFFB54708);
  static const Color warning800 = Color(0xFF93370D);
  static const Color warning900 = Color(0xFF7A2E0E);
  static const Color warning950 = Color(0xFF4E1D09);

  // ============================================================================
  // MÀU BỔ SUNG (Additional Theme Colors)
  // ============================================================================
  static const Color themePink100 = Color(0xFFFCE7F6);
  static const Color themePink500 = Color(0xFFEE46BC);
  static const Color themePurple500 = Color(0xFF7A5AF8);

  // ============================================================================
  // THEME CONFIGURATION
  // ============================================================================

  /// Background gradient cho toàn ứng dụng - Đỏ nhạt sang trắng từ trên xuống
  static const LinearGradient appBackgroundGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 255, 247, 247),
      Color.fromARGB(255, 255, 250, 250),
      Color.fromARGB(255, 255, 253, 253),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.3, 1.0],
  );

  /// Theme sáng (Light Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: brand500,
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme.light(
        primary: brand500,
        secondary: blueLight500,
        surface: white,
        error: error500,
        onPrimary: white,
        onSecondary: white,
        onSurface: gray800,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: gray800,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand500,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: brand500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: brand500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error500),
        ),
      ),
    );
  }

  /// Theme tối (Dark Theme)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: brand400,
      scaffoldBackgroundColor: gray900,
      colorScheme: const ColorScheme.dark(
        primary: brand400,
        secondary: blueLight400,
        surface: gray800,
        error: error400,
        onPrimary: white,
        onSecondary: white,
        onSurface: gray50,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: gray900,
        foregroundColor: gray50,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: gray800,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand400,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: brand400),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gray800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gray700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gray700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: brand400, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error400),
        ),
      ),
    );
  }
}
