import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

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
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

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
              AndroidFlutterLocalNotificationsPlugin>()
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
        debugPrint('FCM: APNs token - ${apnsToken != null ? "Available" : "Not available"}');
      }

      _fcmToken = await _messaging.getToken();
      debugPrint('FCM: Token - $_fcmToken');

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM: Token refreshed - $newToken');
        // TODO: Send new token to your server
        // await ApiService.post('/api/users/fcm-token', {'token': newToken});
      });

      return _fcmToken;
    } catch (e) {
      debugPrint('FCM: Error getting token - $e');
      return null;
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
        payload: message.data.toString(),
      );
    }
  }

  /// Setup interaction handlers (when user taps notification)
  void _setupInteractionHandler() {
    // Handle notification tap when app was terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('FCM: App opened from terminated state');
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
    final type = data['type'];
    final id = data['id'];

    // TODO: Navigate to appropriate screen based on notification type
    // Example:
    // if (type == 'incident' && id != null) {
    //   navigatorKey.currentState?.pushNamed('/incident-detail', arguments: id);
    // } else if (type == 'idea' && id != null) {
    //   navigatorKey.currentState?.pushNamed('/idea-detail', arguments: id);
    // }
  }

  /// Handle notification payload from local notification
  void _handleNotificationPayload(String? payload) {
    if (payload == null) return;
    debugPrint('FCM: Handling payload - $payload');
    // TODO: Parse payload and navigate
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
