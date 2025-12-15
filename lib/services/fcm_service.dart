import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:convert' show jsonDecode, jsonEncode;
import 'api_service.dart';
import '../main.dart' show navigatorKey;
import '../screens/home/news_detail_screen.dart';
import '../screens/idea_box/idea_detail_screen.dart';
import '../screens/report/report_detail_view_screen.dart';
import '../models/news_model.dart';
import '../models/idea_box_model.dart';
import '../models/report_model.dart';

/// FCM Service for handling push notifications
/// Supports: Android, iOS (mobile platforms only)
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  // Notification channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Check if current platform supports FCM
  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Initialize FCM service
  Future<void> initialize() async {
    if (!_isSupportedPlatform) {
      debugPrint('FCM: Platform not supported (Web/Desktop)');
      return;
    }

    try {
      // Request notification permission
      await _requestPermission();

      // Setup local notifications for foreground
      await _setupLocalNotifications();

      // Get FCM token
      await _getToken();

      // Setup message handlers
      _setupForegroundHandler();
      _setupInteractionHandler();

      debugPrint('FCM: Initialized successfully');
    } catch (e) {
      debugPrint('FCM: Initialization error - $e');
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    debugPrint('FCM: Permission status - ${settings.authorizationStatus}');
  }

  /// Setup local notifications plugin
  Future<void> _setupLocalNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('FCM: Local notification tapped - ${details.payload}');
        _handleNotificationPayload(details.payload);
      },
    );

    // Create notification channel for Android
    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    }
  }

  /// Get FCM token
  Future<String?> _getToken() async {
    try {
      // For iOS, ensure APNs token is available first
      if (!kIsWeb && Platform.isIOS) {
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('FCM: Waiting for APNs token...');
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _messaging.getAPNSToken();
        }
        debugPrint(
          'FCM: APNs token - ${apnsToken != null ? "Available" : "Not available"}',
        );
      }

      _fcmToken = await _messaging.getToken();
      debugPrint('FCM: Token - $_fcmToken');

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM: Token refreshed - $newToken');
        // Auto-send to server if user is logged in
        sendTokenToServer();
      });

      return _fcmToken;
    } catch (e) {
      debugPrint('FCM: Error getting token - $e');
      return null;
    }
  }

  /// Send FCM token to server
  /// Call this after user login
  Future<bool> sendTokenToServer() async {
    if (_fcmToken == null || !_isSupportedPlatform) {
      return false;
    }

    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';

      final response = await ApiService.post('/api/users/fcm-token', {
        'token': _fcmToken,
        'devicePlatform': platform,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('FCM: Token sent to server successfully');
        return true;
      } else {
        debugPrint(
          'FCM: Failed to send token to server - ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('FCM: Error sending token to server - $e');
      return false;
    }
  }

  /// Remove FCM token from server
  /// Call this on user logout
  Future<bool> removeTokenFromServer() async {
    if (_fcmToken == null) {
      return false;
    }

    try {
      final response = await ApiService.delete('/api/users/fcm-token');

      if (response.statusCode == 200) {
        debugPrint('FCM: Token removed from server');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('FCM: Error removing token from server - $e');
      return false;
    }
  }

  /// Handle foreground messages
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM: Foreground message received');
      debugPrint('FCM: Title - ${message.notification?.title}');
      debugPrint('FCM: Body - ${message.notification?.body}');
      debugPrint('FCM: Data - ${message.data}');

      // Show local notification when app is in foreground
      _showLocalNotification(message);
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Thông báo mới',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
            enableVibration: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Setup interaction handlers (when user taps notification)
  void _setupInteractionHandler() {
    // Handle notification tap when app was terminated
    debugPrint('FCM: Setting up interaction handler...');
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      debugPrint(
        'FCM: getInitialMessage returned: ${message != null ? "HAS MESSAGE" : "NULL"}',
      );
      if (message != null) {
        debugPrint('FCM: App opened from terminated state');
        debugPrint('FCM: Initial message data: ${message.data}');
        _handleNotificationTap(message);
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM: App opened from background');
      _handleNotificationTap(message);
    });
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('FCM: Notification tapped - ${message.data}');

    // Extract data from notification
    final data = message.data;
    _navigateByNotificationData(data);
  }

  /// Handle notification payload from local notification
  void _handleNotificationPayload(String? payload) {
    if (payload == null) return;
    debugPrint('FCM: Handling payload - $payload');

    // Parse payload JSON string to map
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateByNotificationData(data);
    } catch (e) {
      debugPrint('FCM: Error parsing payload - $e');
    }
  }

  /// Navigate based on notification data
  void _navigateByNotificationData(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final id = data['id']?.toString();
    final actionUrl = data['action_url']?.toString();

    debugPrint(
      'FCM: Navigating - type: $type, id: $id, action_url: $actionUrl',
    );

    if (type == null && actionUrl == null) {
      debugPrint('FCM: No navigation data found');
      return;
    }

    // Use navigatorKey from main.dart
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('FCM: Navigator not available yet');
      // Store pending navigation and try again later
      _pendingNavigationData = data;
      return;
    }

    // Navigate based on type
    switch (type) {
      case 'news':
        _navigateToNewsDetail(navigator, id);
        break;
      case 'incident':
        _navigateToIncidentDetail(navigator, id);
        break;
      case 'idea':
        _navigateToIdeaDetail(navigator, id);
        break;
      default:
        debugPrint('FCM: Unknown notification type - $type');
        // Navigate to notifications screen as fallback
        navigator.pushNamed('/home');
    }
  }

  /// Store pending navigation data
  Map<String, dynamic>? _pendingNavigationData;

  /// Process pending navigation (call after app is fully loaded)
  void processPendingNavigation() {
    debugPrint('FCM: processPendingNavigation called');
    debugPrint('FCM: _pendingNavigationData = $_pendingNavigationData');
    if (_pendingNavigationData != null) {
      debugPrint('FCM: Processing pending navigation now...');
      _navigateByNotificationData(_pendingNavigationData!);
      _pendingNavigationData = null;
    } else {
      debugPrint('FCM: No pending navigation data');
    }
  }

  /// Navigate to news detail
  void _navigateToNewsDetail(NavigatorState navigator, String? newsId) async {
    if (newsId == null) {
      debugPrint('FCM: No news ID provided');
      return;
    }

    try {
      final response = await ApiService.get('/api/news/$newsId');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final newsData = jsonData['data'] as Map<String, dynamic>;
          navigator.push(
            MaterialPageRoute(
              builder: (context) => _buildNewsDetailScreen(newsData),
            ),
          );
        }
      } else {
        debugPrint('FCM: Failed to fetch news - ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('FCM: Error navigating to news - $e');
    }
  }

  /// Navigate to incident detail
  void _navigateToIncidentDetail(
    NavigatorState navigator,
    String? incidentId,
  ) async {
    if (incidentId == null) {
      debugPrint('FCM: No incident ID provided');
      return;
    }

    try {
      // Fetch incident data first
      final response = await ApiService.get('/api/incidents/$incidentId');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final incidentData = jsonData['data'] as Map<String, dynamic>;
          navigator.push(
            MaterialPageRoute(
              builder: (context) => _buildIncidentDetailScreen(incidentData),
            ),
          );
        }
      } else {
        debugPrint('FCM: Failed to fetch incident - ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('FCM: Error navigating to incident - $e');
    }
  }

  /// Navigate to idea detail
  void _navigateToIdeaDetail(NavigatorState navigator, String? ideaId) async {
    if (ideaId == null) {
      debugPrint('FCM: No idea ID provided');
      return;
    }

    try {
      final response = await ApiService.get('/api/ideas/$ideaId');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final ideaData = jsonData['data'] as Map<String, dynamic>;
          navigator.push(
            MaterialPageRoute(
              builder: (context) => _buildIdeaDetailScreen(ideaData),
            ),
          );
        }
      } else {
        debugPrint('FCM: Failed to fetch idea - ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('FCM: Error navigating to idea - $e');
    }
  }

  /// Build news detail screen
  Widget _buildNewsDetailScreen(Map<String, dynamic> newsData) {
    final news = NewsModel.fromJson(newsData);
    return NewsDetailScreen(news: news);
  }

  /// Build incident detail screen
  Widget _buildIncidentDetailScreen(Map<String, dynamic> incidentData) {
    final report = ReportModel.fromJson(incidentData);
    return ReportDetailScreen(report: report);
  }

  /// Build idea detail screen
  Widget _buildIdeaDetailScreen(Map<String, dynamic> ideaData) {
    final idea = IdeaBoxItem.fromJson(ideaData);
    return IdeaDetailScreen(idea: idea);
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    if (!_isSupportedPlatform) return;

    await _messaging.subscribeToTopic(topic);
    debugPrint('FCM: Subscribed to topic - $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_isSupportedPlatform) return;

    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('FCM: Unsubscribed from topic - $topic');
  }
}
