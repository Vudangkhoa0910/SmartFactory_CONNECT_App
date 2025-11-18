import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/loading_overlay.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';

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
  String _biometricType = 'Sinh trắc học';

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
    final authenticated = await _authService.authenticateWithBiometric(
      reason: 'Xác thực để đăng nhập vào SmartFactory Connect',
    );

    if (authenticated && mounted) {
      // Đăng nhập thành công
      _navigateToHome();
    }
  }

  /// Xử lý đăng nhập
  Future<void> _handleLogin() async {
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
        );

        // Cập nhật UserProvider và đợi hoàn tất
        final userProvider = UserProvider();
        await userProvider.setUserRole(result['role'] ?? 'user');

        // Đảm bảo UserProvider đã load xong
        while (!userProvider.isLoaded) {
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Navigate to home
        _navigateToHome();
      } else {
        // Hiển thị lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Đăng nhập thất bại'),
              backgroundColor: AppColors.error500,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Có lỗi xảy ra. Vui lòng thử lại'),
            backgroundColor: AppColors.error500,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
                            'Đăng nhập để tiếp tục',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray600,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 40),

                          // Username field
                          TextFormField(
                            controller: _usernameController,
                            style: TextStyle(color: AppColors.black),
                            decoration: InputDecoration(
                              labelText: 'Tên đăng nhập hoặc Email',
                              hintText: 'Nhập tên đăng nhập hoặc email',
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
                                return 'Vui lòng nhập tên đăng nhập hoặc email';
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
                              labelText: 'Mật khẩu',
                              hintText: 'Nhập mật khẩu',
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
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 6) {
                                return 'Mật khẩu phải có ít nhất 6 ký tự';
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
                                'Ghi nhớ đăng nhập',
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
                                'Đăng nhập',
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
                                        'Hoặc',
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
                                      'Đăng nhập bằng $_biometricType',
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
