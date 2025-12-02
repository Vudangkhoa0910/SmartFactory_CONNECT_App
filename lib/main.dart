import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:toastification/toastification.dart';
import 'dart:io';
import 'l10n/app_localizations.dart';
import 'splash_screen.dart';
import 'bottom_nav_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/report/report_form_screen.dart';
import 'screens/report/leader_report_form_screen.dart';
import 'config/app_colors.dart';
import 'providers/language_provider.dart';

/// Global navigator key for toast notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved language preference
  await LanguageProvider().loadSavedLanguage();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LanguageProvider _languageProvider = LanguageProvider();

  @override
  void initState() {
    super.initState();
    _languageProvider.addListener(_onLanguageChanged);
    _setHighRefreshRate();
  }

  Future<void> _setHighRefreshRate() async {
    try {
      if (Platform.isAndroid) {
        await FlutterDisplayMode.setHighRefreshRate();
      }
    } catch (e) {
      debugPrint('Error setting high refresh rate: $e');
    }
  }

  @override
  void dispose() {
    _languageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'SmartFactory Connect',
        debugShowCheckedModeBanner: false,

        // Localization
        locale: _languageProvider.currentLocale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LanguageProvider.supportedLocales,

        theme: AppColors.lightTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        darkTheme: AppColors.darkTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const BottomNavScreen(),
          '/report-form': (context) => const ReportFormScreen(),
          '/leader-report-form': (context) => const LeaderReportFormScreen(),
        },
      ),
    );
  }
}
