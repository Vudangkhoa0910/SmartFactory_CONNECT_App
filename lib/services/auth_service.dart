import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'api_service.dart';
import 'api_constants.dart';
import 'fcm_service.dart';

/// Service quản lý authentication và lưu trữ thông tin đăng nhập
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Keys for storage
  static const String _keyUsername = 'saved_username';
  static const String _keyPassword = 'saved_password';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserIdentifier = 'user_identifier';
  static const String _keyAuthToken = 'auth_token';

  /// Khởi tạo service (load token nếu có)
  Future<void> initialize() async {
    try {
      final token = await _secureStorage.read(key: _keyAuthToken);
      if (token != null) {
        ApiService.setAuthToken(token);
      }
    } catch (e) {
      // Handle corrupted secure storage data (e.g. after backup restore or encryption key change)
      // Clear all secure storage data and let user re-login
      print('AuthService: Error reading secure storage, clearing corrupted data: $e');
      await _clearCorruptedSecureStorage();
    }
  }

  /// Clear all secure storage when data is corrupted
  Future<void> _clearCorruptedSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
      ApiService.setAuthToken(null);
      
      // Also clear shared preferences login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyRememberMe);
    } catch (e) {
      print('AuthService: Error clearing secure storage: $e');
    }
  }

  /// Lưu thông tin đăng nhập
  Future<void> saveCredentials({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final biometricEnabled = prefs.getBool(_keyBiometricEnabled) ?? false;

    if (rememberMe || biometricEnabled) {
      // Lưu username và password vào secure storage
      await _secureStorage.write(key: _keyUsername, value: username);
      await _secureStorage.write(key: _keyPassword, value: password);
    } else {
      // Xóa credentials nếu không remember và không bật biometric
      await _secureStorage.delete(key: _keyUsername);
      await _secureStorage.delete(key: _keyPassword);
    }

    if (rememberMe) {
      await prefs.setBool(_keyRememberMe, true);
    } else {
      await prefs.setBool(_keyRememberMe, false);
    }

    // Đánh dấu đã đăng nhập
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Lấy thông tin đăng nhập đã lưu
  Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final username = await _secureStorage.read(key: _keyUsername);
      final password = await _secureStorage.read(key: _keyPassword);
      return {'username': username, 'password': password};
    } catch (e) {
      print('AuthService: Error reading credentials, clearing corrupted data: $e');
      await _clearCorruptedSecureStorage();
      return {'username': null, 'password': null};
    }
  }

  /// Kiểm tra có remember me không
  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Check flag
    final isLogged = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLogged) return false;

    // 2. Check token (with error handling for corrupted storage)
    try {
      final token = await _secureStorage.read(key: _keyAuthToken);
      if (token == null || token.isEmpty) return false;
    } catch (e) {
      print('AuthService: Error checking login status, clearing corrupted data: $e');
      await _clearCorruptedSecureStorage();
      return false;
    }

    // 3. Check Remember Me
    // If Remember Me is disabled, the session should not persist across restarts
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    if (!rememberMe) return false;

    return true;
  }

  /// Xóa thông tin đăng nhập
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyUsername);
    await _secureStorage.delete(key: _keyPassword);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, false);
  }

  /// Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);

    // Remove FCM token from server
    await FCMService().removeTokenFromServer();

    // Không xóa credentials nếu remember me enabled HOẶC biometric enabled
    final rememberMe = await isRememberMeEnabled();
    final biometricEnabled = await isBiometricEnabled();

    if (!rememberMe && !biometricEnabled) {
      await clearCredentials();
    }

    // Xóa thông tin user
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyUserFullName);
    await prefs.remove(_keyUserIdentifier);

    // Xóa token
    await _secureStorage.delete(key: _keyAuthToken);
    ApiService.setAuthToken(null);
  }

  /// Lưu thông tin user sau khi đăng nhập thành công
  Future<void> saveUserInfo({
    required String fullName,
    required String role,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserFullName, fullName);
    await prefs.setString(_keyUserRole, role);
    await prefs.setString(_keyUserIdentifier, username);
  }

  /// Lấy thông tin user
  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fullName': prefs.getString(_keyUserFullName),
      'role': prefs.getString(_keyUserRole),
      'username': prefs.getString(_keyUserIdentifier),
    };
  }

  /// Lấy profile user từ API backend
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiService.get(ApiConstants.profile);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {'success': true, 'data': responseData['data']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== BIOMETRIC AUTHENTICATION ====================

  /// Kiểm tra thiết bị có hỗ trợ sinh trắc học không
  Future<bool> canUseBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Lấy danh sách các loại sinh trắc học có sẵn
  /// iOS: face, fingerprint
  /// Android: fingerprint, iris, face
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate with biometrics
  /// [localizedReason] should be passed from UI with translated text
  Future<bool> authenticateWithBiometric({
    String? localizedReason,
    String? reason, // Backward compatibility - alias for localizedReason
  }) async {
    try {
      final canUse = await canUseBiometric();
      if (!canUse) return false;

      final reasonText = localizedReason ?? reason ?? 'Xác thực để đăng nhập';
      return await _localAuth.authenticate(localizedReason: reasonText);
    } catch (e) {
      return false;
    }
  }

  /// Bật/tắt sinh trắc học cho đăng nhập
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  /// Kiểm tra sinh trắc học có được bật không
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  /// Get biometric type key for UI translation
  /// Returns: 'face', 'fingerprint', 'iris', or 'biometric' (generic)
  Future<String> getBiometricTypeKey() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.isEmpty) return 'biometric';

    if (biometrics.contains(BiometricType.face)) {
      return 'face';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'fingerprint';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'iris';
    } else {
      return 'biometric';
    }
  }

  /// Backward compatibility - return Vietnamese name
  Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.isEmpty) return 'Sinh trắc học';

    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Vân tay';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Mống mắt';
    } else {
      return 'Sinh trắc học';
    }
  }

  /// Verify if the current token is valid by checking with backend
  Future<bool> verifyTokenWithBackend() async {
    try {
      // Ping health endpoint to check if server is reachable
      final healthCheck = await ApiService.pingHealth();
      if (!healthCheck['success']) {
        return false;
      }

      // If we have a token, try to verify it
      final token = await _secureStorage.read(key: _keyAuthToken);
      if (token == null || token.isEmpty) {
        return false;
      }

      // Try to call an authenticated endpoint to verify token
      // Using /api/auth/verify or similar endpoint
      final response = await ApiService.get(ApiConstants.verifyToken);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      // Network error or server unreachable
      return false;
    }
  }

  /// Xác thực user với Backend API
  Future<Map<String, dynamic>> authenticateUser({
    required String username,
    required String password,
  }) async {
    try {
      // Determine if input is email or employee code
      final isEmail = username.contains('@');

      final body = {
        if (isEmail) 'email': username else 'employee_code': username,
        'password': password,
      };

      final response = await ApiService.post(ApiConstants.login, body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'];
        final token = data['token'];
        final user = data['user'];

        // Save token
        await _secureStorage.write(key: _keyAuthToken, value: token);
        ApiService.setAuthToken(token);

        // Map backend role to app role (if needed)
        // Backend roles: admin, manager, supervisor, team_leader, operator, etc.
        // App roles: leader, worker (simplified for now based on previous code)
        // Logic: Level <= 5 (Team Leader and above) -> leader, else -> worker
        final int level = user['level'] ?? 10;
        final String appRole = level <= 5 ? 'leader' : 'worker';

        return {
          'success': true,
          'fullName': user['full_name'],
          'role': appRole, // Mapped role
          'originalRole': user['role'], // Keep original role just in case
          'department': user['department'] != null
              ? user['department']['name']
              : '',
          'employeeId': user['employee_code'],
          'username': username,
          'userId': user['id'],
        };
      } else {
        return {
          'success': false,
          'errorKey': 'login_failed',
          'message': responseData['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'errorKey': 'connection_error',
        'error': e.toString(),
      };
    }
  }
}
