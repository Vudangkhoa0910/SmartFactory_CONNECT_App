import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../providers/language_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/toast_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final LanguageProvider _languageProvider = LanguageProvider();

  bool _isLoading = false;
  bool _biometricEnabled = false;
  bool _canUseBiometric = false;
  String _biometricType = '';

  @override
  void initState() {
    super.initState();
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
    final l10n = AppLocalizations.of(context)!;
    if (value) {
      // 1. Check if we have credentials
      final credentials = await _authService.getSavedCredentials();
      final savedUsername = credentials['username'];
      final savedPassword = credentials['password'];

      if (savedUsername == null || savedPassword == null) {
        // Credentials missing (Remember Me was off)
        // We need to ask for password to enable Biometrics
        if (mounted) {
          _showPasswordPromptDialog();
        }
        return;
      }

      // 2. Authenticate with Biometric to confirm
      final authenticated = await _authService.authenticateWithBiometric(
        reason: l10n.pleaseAuthenticate,
      );

      if (authenticated) {
        await _authService.setBiometricEnabled(true);
        setState(() {
          _biometricEnabled = true;
        });
        _showMessage(l10n.success);
      } else {
        _showMessage(l10n.biometricAuthFailed, isError: true);
      }
    } else {
      await _authService.setBiometricEnabled(false);
      setState(() {
        _biometricEnabled = false;
      });
      _showMessage(l10n.success);
    }
  }

  Future<void> _showPasswordPromptDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final userInfo = await _authService.getUserInfo();
    final username = userInfo['username'] ?? '';

    if (username.isEmpty) {
      _showMessage(l10n.errorUnauthorized, isError: true);
      return;
    }

    final passwordController = TextEditingController();
    bool isObscure = true;

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.confirmPassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.pleaseAuthenticate,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => isObscure = !isObscure);
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final password = passwordController.text;
                if (password.isEmpty) return;
                Navigator.pop(context);
                _verifyAndEnableBiometric(username, password);
              },
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyAndEnableBiometric(
    String username,
    String password,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final result = await _authService.authenticateUser(
        username: username,
        password: password,
      );

      if (result['success'] == true) {
        final authenticated = await _authService.authenticateWithBiometric(
          reason: l10n.pleaseAuthenticate,
        );

        if (authenticated) {
          await _authService.setBiometricEnabled(true);

          // Save credentials (rememberMe = false)
          await _authService.saveCredentials(
            username: username,
            password: password,
            rememberMe: false,
          );

          setState(() {
            _biometricEnabled = true;
          });
          _showMessage(l10n.success);
        } else {
          _showMessage(l10n.biometricAuthFailed, isError: true);
        }
      } else {
        _showMessage(l10n.invalidCredentials, isError: true);
      }
    } catch (e) {
      _showMessage('${l10n.error}: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (isError) {
      ToastUtils.showError(message);
    } else {
      ToastUtils.showSuccess(message);
    }
  }

  Widget _buildLanguageOption({
    required String flag,
    required String name,
    required Locale locale,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () async {
        await _languageProvider.setLanguage(locale);
        setState(() {});
        _showMessage(AppLocalizations.of(context)!.success);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.brand500 : AppColors.gray900,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.brand500, size: 22)
            else
              Icon(Icons.circle_outlined, color: AppColors.gray300, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
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
            AppLocalizations.of(context)!.settings,
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
                      AppLocalizations.of(context)!.privacy,
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
                                  AppLocalizations.of(context)!.biometricLogin,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(context)!.useBiometric,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleBiometric(!_biometricEnabled),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 50,
                              height: 30,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: _biometricEnabled
                                    ? AppColors.brand500
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _biometricEnabled
                                      ? AppColors.brand500
                                      : AppColors.gray300,
                                  width: 2,
                                ),
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 200),
                                alignment: _biometricEnabled
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _biometricEnabled
                                        ? Colors.white
                                        : AppColors.gray400,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ========== LANGUAGE SETTINGS ==========
                  Text(
                    AppLocalizations.of(context)!.language,
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
                      vertical: 8,
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
                    child: Column(
                      children: [
                        // Vietnamese
                        _buildLanguageOption(
                          flag: '🇻🇳',
                          name: 'Tiếng Việt',
                          locale: LanguageProvider.vietnamese,
                          isSelected: _languageProvider.isVietnamese,
                        ),
                        Divider(height: 1, color: AppColors.gray100),
                        // Japanese
                        _buildLanguageOption(
                          flag: '🇯🇵',
                          name: '日本語 (Japanese)',
                          locale: LanguageProvider.japanese,
                          isSelected: _languageProvider.isJapanese,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
