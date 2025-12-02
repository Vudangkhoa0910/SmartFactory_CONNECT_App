import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider để quản lý ngôn ngữ của ứng dụng
/// Hỗ trợ: Tiếng Việt (vi) và Tiếng Nhật (ja)
class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  // Singleton pattern
  static final LanguageProvider _instance = LanguageProvider._internal();
  factory LanguageProvider() => _instance;
  LanguageProvider._internal();

  // Supported locales
  static const Locale vietnamese = Locale('vi');
  static const Locale japanese = Locale('ja');

  static const List<Locale> supportedLocales = [vietnamese, japanese];

  // Current locale
  Locale _currentLocale = vietnamese;
  Locale get currentLocale => _currentLocale;

  // Language display names
  static const Map<String, String> languageNames = {
    'vi': 'Tiếng Việt',
    'ja': '日本語',
  };

  // Language flags (emoji)
  static const Map<String, String> languageFlags = {'vi': '🇻🇳', 'ja': '🇯🇵'};

  /// Load saved language preference
  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading language preference: $e');
    }
  }

  /// Change app language
  Future<void> setLanguage(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      print('Error saving language preference: $e');
    }
  }

  /// Toggle between Vietnamese and Japanese
  Future<void> toggleLanguage() async {
    final newLocale = _currentLocale.languageCode == 'vi'
        ? japanese
        : vietnamese;
    await setLanguage(newLocale);
  }

  /// Get display name for current language
  String get currentLanguageName =>
      languageNames[_currentLocale.languageCode] ?? 'Tiếng Việt';

  /// Get flag for current language
  String get currentLanguageFlag =>
      languageFlags[_currentLocale.languageCode] ?? '🇻🇳';

  /// Check if current language is Vietnamese
  bool get isVietnamese => _currentLocale.languageCode == 'vi';

  /// Check if current language is Japanese
  bool get isJapanese => _currentLocale.languageCode == 'ja';
}
