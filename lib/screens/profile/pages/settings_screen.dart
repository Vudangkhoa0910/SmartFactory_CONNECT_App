import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isTesting = false;
  bool _biometricEnabled = false;
  bool _canUseBiometric = false;
  String _biometricType = 'Sinh trắc học';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final canUse = await _authService.canUseBiometric();
    final enabled = await _authService.isBiometricEnabled();
    final typeName = await _authService.getBiometricTypeName();
    
    setState(() {
      _canUseBiometric = canUse;
      _biometricEnabled = enabled;
      _biometricType = typeName;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Yêu cầu xác thực trước khi bật
      final authenticated = await _authService.authenticateWithBiometric(
        reason: 'Xác thực để bật $_biometricType cho đăng nhập',
      );
      
      if (authenticated) {
        await _authService.setBiometricEnabled(true);
        setState(() {
          _biometricEnabled = true;
        });
        _showMessage('Đã bật $_biometricType cho đăng nhập');
      } else {
        _showMessage('Xác thực thất bại', isError: true);
      }
    } else {
      await _authService.setBiometricEnabled(false);
      setState(() {
        _biometricEnabled = false;
      });
      _showMessage('Đã tắt $_biometricType');
    }
  }

  Future<void> _loadSettings() async {
    final ip = await ApiService.getServerIp();
    final port = await ApiService.getServerPort();
    setState(() {
      _ipController.text = ip;
      _portController.text = port;
    });
  }

  Future<void> _saveSettings() async {
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();

    if (ip.isEmpty || port.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ IP và Port', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.setServerIp(ip);
      await ApiService.setServerPort(port);

      if (mounted) {
        _showMessage('Đã lưu cấu hình: $ip:$port');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Lỗi lưu cấu hình: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testConnection() async {
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();

    if (ip.isEmpty || port.isEmpty) {
      _showMessage('Vui lòng nhập IP và Port trước', isError: true);
      return;
    }

    setState(() => _isTesting = true);

    try {
      // Save temporarily for test
      await ApiService.setServerIp(ip);
      await ApiService.setServerPort(port);

      // Test connection
      final result = await ApiService.pingHealth();

      if (mounted) {
        _showMessage(result['message'], isError: !result['success']);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Lỗi kiểm tra: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error500 : AppColors.success500,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 247, 247),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 247, 247),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.gray900),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Cài đặt',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.appBackgroundGradient,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========== SECURITY SETTINGS ==========
                  if (_canUseBiometric) ...[
                    Text(
                      'Bảo mật',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.brand50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _biometricType == 'Face ID' 
                                  ? Icons.face 
                                  : Icons.fingerprint,
                              color: AppColors.brand500,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đăng nhập bằng $_biometricType',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Đăng nhập nhanh và bảo mật hơn',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _biometricEnabled,
                            onChanged: _toggleBiometric,
                            activeColor: AppColors.brand500,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ========== SERVER SETTINGS ==========
                  Text(
                    'Cài đặt Server',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // IP:Port input in one line
                  Row(
                    children: [
                      // IP Address input
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _ipController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'IP',
                              labelStyle: TextStyle(
                                color: AppColors.gray600,
                                fontSize: 12,
                              ),
                              hintText: '192.168.1.100',
                              hintStyle: TextStyle(
                                color: AppColors.gray400,
                                fontSize: 12,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: AppColors.gray300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: AppColors.gray300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: AppColors.brand500,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                      // Port input
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _portController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Port',
                              labelStyle: TextStyle(
                                color: AppColors.gray600,
                                fontSize: 12,
                              ),
                              hintText: '8080',
                              hintStyle: TextStyle(
                                color: AppColors.gray400,
                                fontSize: 12,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: AppColors.gray300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: AppColors.gray300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: AppColors.brand500,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Test connection button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isTesting ? null : _testConnection,
                      icon: _isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.wifi_find, color: AppColors.brand500),
                      label: Text(
                        _isTesting ? 'Đang kiểm tra...' : 'Kiểm tra kết nối',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brand500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.brand500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _isTesting)
                          ? null
                          : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand500,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Lưu cấu hình',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.gray600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Endpoint kiểm tra: /health\nVí dụ: http://192.168.1.10:8080/health',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
