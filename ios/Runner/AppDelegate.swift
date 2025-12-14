import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Ensure native Firebase is configured (no-op if already configured in Dart)
    var configureError: NSError?
    if FIRAppConfigureSafe(&configureError) {
      print("FCM DEBUG: Firebase configured (native).")
    } else {
      let errDesc = configureError?.localizedDescription ?? "(no error info)"
      print("FCM DEBUG: Firebase configure failed: \(errDesc)")
    }

    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self

    // Request notification permissions
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
      if let error = error {
        print("FCM DEBUG: requestAuthorization error: \(error.localizedDescription)")
      }
      print("FCM DEBUG: notification permission granted = \(granted)")
    }

    // Register with APNs
    print("FCM DEBUG: registering for remote notifications")
    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Forward APNs token to Firebase Messaging
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("FCM DEBUG: didRegisterForRemoteNotificationsWithDeviceToken (hex): \(tokenString)")
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("FCM DEBUG: didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
  
  // Messaging delegate to log FCM token
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("FCM DEBUG: didReceiveRegistrationToken: \(fcmToken ?? "(nil)")")
  }
}
