import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

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

  /// Lưu thông tin đăng nhập
  Future<void> saveCredentials({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (rememberMe) {
      // Lưu username và password vào secure storage
      await _secureStorage.write(key: _keyUsername, value: username);
      await _secureStorage.write(key: _keyPassword, value: password);
      await prefs.setBool(_keyRememberMe, true);
    } else {
      // Xóa credentials nếu không remember
      await clearCredentials();
    }

    // Đánh dấu đã đăng nhập
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Lấy thông tin đăng nhập đã lưu
  Future<Map<String, String?>> getSavedCredentials() async {
    final username = await _secureStorage.read(key: _keyUsername);
    final password = await _secureStorage.read(key: _keyPassword);

    return {'username': username, 'password': password};
  }

  /// Kiểm tra có remember me không
  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
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

    // Không xóa credentials nếu remember me enabled
    final rememberMe = await isRememberMeEnabled();
    if (!rememberMe) {
      await clearCredentials();
    }

    // Xóa thông tin user
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyUserFullName);
  }

  /// Lưu thông tin user sau khi đăng nhập thành công
  Future<void> saveUserInfo({
    required String fullName,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserFullName, fullName);
    await prefs.setString(_keyUserRole, role);
  }

  /// Lấy thông tin user
  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fullName': prefs.getString(_keyUserFullName),
      'role': prefs.getString(_keyUserRole),
    };
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

  /// Xác thực bằng sinh trắc học
  Future<bool> authenticateWithBiometric({
    String reason = 'Xác thực để đăng nhập',
  }) async {
    try {
      final canUse = await canUseBiometric();
      if (!canUse) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true, // Không bị hủy khi chuyển app
          biometricOnly: true, // Chỉ dùng sinh trắc, không dùng PIN
        ),
      );
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

  /// Lấy tên loại sinh trắc học (để hiển thị)
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

  /// Demo: Xác thực user với 2 tài khoản demo
  /// WORKER: user: worker, pass: 123456
  /// LEADER: user: leader, pass: 123456
  Future<Map<String, dynamic>> authenticateUser({
    required String username,
    required String password,
  }) async {
    // Giả lập delay API call
    await Future.delayed(const Duration(milliseconds: 800));

    final String user = username.toLowerCase().trim();
    final String pass = password.trim();

    // Demo accounts
    const Map<String, Map<String, String>> demoAccounts = {
      'worker': {
        'password': '123456',
        'fullName': 'Nguyễn Văn A',
        'role': 'worker',
        'department': 'Sản xuất',
        'employeeId': 'EMP001',
      },
      'leader': {
        'password': '123456',
        'fullName': 'Trần Thị Q',
        'role': 'leader',
        'department': 'Quản lý sản xuất',
        'employeeId': 'MGR001',
      },
    };

    if (demoAccounts.containsKey(user)) {
      final account = demoAccounts[user]!;
      if (account['password'] == pass) {
        return {
          'success': true,
          'fullName': account['fullName'],
          'role': account['role'],
          'department': account['department'],
          'employeeId': account['employeeId'],
          'username': username,
        };
      }
    }

    return {
      'success': false,
      'message':
          'Tài khoản demo:\n• Worker: user=worker, pass=123456\n• Leader: user=leader, pass=123456',
    };
  }
}
