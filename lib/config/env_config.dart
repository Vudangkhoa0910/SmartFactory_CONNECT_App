import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the app
/// Loads configuration from environment variables
class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  String? _geminiApiKey;
  String? _geminiModel;
  bool _isLoaded = false;

  /// Get Gemini API Key
  String get geminiApiKey => _geminiApiKey ?? '';

  /// Get Gemini Model name
  String get geminiModel => _geminiModel ?? 'gemini-1.5-flash';

  /// Check if API key is configured
  bool get hasGeminiApiKey =>
      _geminiApiKey != null &&
      _geminiApiKey!.isNotEmpty &&
      _geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE';

  /// Load environment variables from .env file
  Future<void> load() async {
    if (_isLoaded) return;

    try {
      // Load from .env file
      await dotenv.load(fileName: ".env");

      _geminiApiKey = dotenv.env['GEMINI_API_KEY'];
      _geminiModel = dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash';

      _isLoaded = true;
    } catch (e) {
      print('Error loading env config: $e');
      // Fallback to compile-time constants if .env fails
      _loadFromEnvFile();
      _isLoaded = true;
    }
  }

  Future<void> _loadFromEnvFile() async {
    // Default values - replace with your actual API key
    // In production, use --dart-define or a secure method
    _geminiApiKey = const String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: '',
    );
    _geminiModel = const String.fromEnvironment(
      'GEMINI_MODEL',
      defaultValue: 'gemini-1.5-flash',
    );
  }

  /// Set API key programmatically (useful for testing or runtime config)
  void setGeminiApiKey(String apiKey) {
    _geminiApiKey = apiKey;
  }
}
