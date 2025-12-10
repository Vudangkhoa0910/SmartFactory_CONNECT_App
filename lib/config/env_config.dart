import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the app
/// Loads configuration from environment variables
/// 
/// NOTE: Gemini API key is no longer needed on mobile app.
/// AI calls now go through backend API for security.
class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  bool _isLoaded = false;

  /// Load environment variables from .env file
  /// Now only loads app-specific settings, not AI keys
  Future<void> load() async {
    if (_isLoaded) return;

    try {
      // Load from .env file for any app-specific settings
      await dotenv.load(fileName: ".env");
      _isLoaded = true;
    } catch (e) {
      print('Note: .env file not found or empty - using defaults');
      _isLoaded = true;
    }
  }

  /// Check if environment is loaded
  bool get isLoaded => _isLoaded;

  // ========================================
  // DEPRECATED: Gemini API configuration
  // AI calls now go through backend API
  // These are kept for backward compatibility
  // but values are no longer used
  // ========================================
  
  @Deprecated('AI calls now go through backend API')
  String get geminiApiKey => '';
  
  @Deprecated('AI calls now go through backend API')
  String get geminiModel => 'gemini-1.5-flash';
  
  @Deprecated('AI calls now go through backend API')
  bool get hasGeminiApiKey => false;
  
  @Deprecated('AI calls now go through backend API')
  void setGeminiApiKey(String apiKey) {
    // No-op: API key is now managed by backend
  }
}
