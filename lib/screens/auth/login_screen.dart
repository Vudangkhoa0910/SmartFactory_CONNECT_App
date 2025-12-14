import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/language_toggle_button.dart';
import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';
import '../../providers/user_provider.dart';
import '../../utils/toast_utils.dart';

/// Màn hình đăng nhập
/// User nhập username/email và password để đăng nhập
/// Hỗ trợ: Remember Me, Auto Login, Biometric Authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _canUseBiometric = false;
  String _biometricType = '';

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  /// Khởi tạo và kiểm tra trạng thái authentication
  Future<void> _initializeAuth() async {
    // Kiểm tra thiết bị có hỗ trợ sinh trắc học không
    final canUse = await _authService.canUseBiometric();
    final biometricName = await _authService.getBiometricTypeName();

    setState(() {
      _canUseBiometric = canUse;
      _biometricType = biometricName;
    });

    // Tự động load thông tin đăng nhập đã lưu
    await _loadSavedCredentials();

    // Nếu đã đăng nhập và có bật sinh trắc học, tự động xác thực
    final isLoggedIn = await _authService.isLoggedIn();
    final biometricEnabled = await _authService.isBiometricEnabled();

    if (isLoggedIn && biometricEnabled && _canUseBiometric) {
      // Delay một chút để UI render xong
      await Future.delayed(const Duration(milliseconds: 500));
      _authenticateWithBiometric();
    }
  }

  /// Load thông tin đăng nhập đã lưu
  Future<void> _loadSavedCredentials() async {
    final rememberMe = await _authService.isRememberMeEnabled();

    if (rememberMe) {
      final credentials = await _authService.getSavedCredentials();
      setState(() {
        _rememberMe = true;
        _usernameController.text = credentials['username'] ?? '';
        _passwordController.text = credentials['password'] ?? '';
      });
    }
  }

  /// Xác thực bằng sinh trắc học
  Future<void> _authenticateWithBiometric() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Xác thực sinh trắc học (Local Auth)
    final authenticated = await _authService.authenticateWithBiometric(
      reason: l10n.pleaseAuthenticate,
    );

    if (!authenticated) return;

    // 2. Lấy thông tin đăng nhập đã lưu
    final credentials = await _authService.getSavedCredentials();
    final username = credentials['username'];
    final password = credentials['password'];

    if (username != null && password != null) {
      // 3. Tự động đăng nhập lại với API
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      try {
        final result = await _authService.authenticateUser(
          username: username,
          password: password,
        );

        if (!mounted) return;

        if (result['success'] == true) {
          // Cập nhật UserProvider
          final userProvider = UserProvider();
          await userProvider.setUserRole(result['role'] ?? 'user');

          // Đảm bảo UserProvider đã load xong
          while (!userProvider.isLoaded) {
            await Future.delayed(const Duration(milliseconds: 50));
          }

          // Register FCM token with server
          await FCMService().sendTokenToServer();

          _navigateToHome();
        } else {
          ToastUtils.showError(
            '${l10n.loginFailed}: ${result['message'] ?? l10n.errorGeneral}',
          );
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError(l10n.errorNetwork);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // Trường hợp không có credentials (ví dụ: token còn hạn nhưng không có pass)
      // Thử navigate luôn nếu đang logged in
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _navigateToHome();
      } else {
        if (mounted) {
          ToastUtils.showWarning(l10n.orLoginWithPassword);
        }
      }
    }
  }

  /// Xử lý đăng nhập
  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi API authentication
      final result = await _authService.authenticateUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Lưu thông tin đăng nhập
        await _authService.saveCredentials(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );

        // Lưu thông tin user
        await _authService.saveUserInfo(
          fullName: result['fullName'] ?? 'User',
          role: result['role'] ?? 'user',
          username: result['username'] ?? _usernameController.text.trim(),
        );

        // Cập nhật UserProvider và đợi hoàn tất
        final userProvider = UserProvider();
        await userProvider.setUserRole(result['role'] ?? 'user');

        // Đảm bảo UserProvider đã load xong
        while (!userProvider.isLoaded) {
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Register FCM token with server
        await FCMService().sendTokenToServer();

        // Navigate to home
        _navigateToHome();
      } else {
        // Hiển thị lỗi
        if (mounted) {
          ToastUtils.showError(result['message'] ?? l10n.loginFailed);
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(l10n.errorGeneral);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Navigate to home screen
  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.appBackgroundGradient,
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          SvgPicture.asset(
                            'assets/logo-denso.svg',
                            width: 60,
                            height: 60,
                          ),

                          const SizedBox(height: 32),

                          // Title
                          Text(
                            'SmartFactory CONNECT',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            l10n.loginSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray600,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Language Toggle Button
                          const LanguageToggleButton(),

                          const SizedBox(height: 40),

                          // Username field
                          TextFormField(
                            controller: _usernameController,
                            style: TextStyle(color: AppColors.black),
                            decoration: InputDecoration(
                              labelText: l10n.employeeId,
                              hintText: l10n.enterEmployeeId,
                              labelStyle: TextStyle(color: AppColors.gray600),
                              hintStyle: TextStyle(color: AppColors.gray400),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.gray400,
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.gray200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.gray200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.brand500,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.error500,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterEmployeeId;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: TextStyle(color: AppColors.black),
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              hintText: l10n.enterPassword,
                              labelStyle: TextStyle(color: AppColors.gray600),
                              hintStyle: TextStyle(color: AppColors.gray400),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.gray400,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.gray400,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.gray200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.gray200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.brand500,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.error500,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterPassword;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Remember Me checkbox
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.brand500,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.rememberMe,
                                style: TextStyle(
                                  color: AppColors.gray700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      // Dismiss keyboard
                                      FocusScope.of(context).unfocus();
                                      _handleLogin();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brand500,
                                disabledBackgroundColor: AppColors.gray300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                padding: EdgeInsets.zero, // Remove padding
                              ),
                              child: Text(
                                l10n.loginButton,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Biometric login button (if available)
                          if (_canUseBiometric)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(color: AppColors.gray300),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        l10n.orLoginWithPassword.split(
                                          ' ',
                                        )[0], // "Hoặc" / "または"
                                        style: TextStyle(
                                          color: AppColors.gray500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(color: AppColors.gray300),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton.icon(
                                    onPressed: _authenticateWithBiometric,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: AppColors.brand500,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: Icon(
                                      _biometricType == 'Face ID'
                                          ? Icons.face
                                          : Icons.fingerprint,
                                      color: AppColors.brand500,
                                      size: 24,
                                    ),
                                    label: Text(
                                      l10n.loginWithBiometric,
                                      style: TextStyle(
                                        color: AppColors.brand500,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 40),

                          // App version
                          Text(
                            'SmartFactory CONNECT v1.0.0',
                            style: TextStyle(
                              color: AppColors.gray400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Loading overlay
            LoadingOverlay(isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
