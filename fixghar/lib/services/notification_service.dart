import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles Firebase Cloud Messaging (FCM) push notifications for FixGhar
/// This is a placeholder implementation — wire up actual notification handling
/// by registering background handlers and connecting to your backend.
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Call this once during app startup (before runApp or in main)
  /// Requests permission, gets the FCM token, and registers listeners
  Future<void> init() async {
    // 1. Request notification permissions from the user
    await _requestPermission();

    // 2. Get the FCM device token (send this to your backend/Firestore to
    //    enable targeted push notifications for this device)
    await _getFcmToken();

    // 3. Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. Handle tap on notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 5. Check for notification that launched the app from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  // ---------------------------------------------------------------------------
  // Permission
  // ---------------------------------------------------------------------------

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // true = provisional (iOS 12+), silent delivery
    );

    if (kDebugMode) {
      debugPrint(
        '[FCM] Permission status: ${settings.authorizationStatus.name}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // FCM Token
  // ---------------------------------------------------------------------------

  /// Retrieves the FCM device token — save this to Firestore under the user's
  /// document so your backend can send targeted notifications
  Future<String?> _getFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('[FCM] Token: $token');
      }
      return token;
    } catch (e) {
      debugPrint('[FCM] Failed to get token: $e');
      return null;
    }
  }

  /// Public method to retrieve and return the current FCM token
  Future<String?> getToken() => _getFcmToken();

  /// Saves the FCM token to Firestore under the user's document
  /// Call this after the user logs in so notifications can be targeted
  Future<void> saveTokenToFirestore({
    required String userId,
    required Future<void> Function(String userId, String token) onSave,
  }) async {
    final token = await _getFcmToken();
    if (token != null) {
      await onSave(userId, token);
    }
  }

  // ---------------------------------------------------------------------------
  // Message Handlers
  // ---------------------------------------------------------------------------

  /// Called when a push notification arrives while the app is in the foreground
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM] Foreground message: ${message.notification?.title}');
      debugPrint('[FCM] Data: ${message.data}');
    }
    // TODO: Show an in-app banner or update UI state based on message.data
    // e.g. if data['type'] == 'booking_confirmed' -> refresh bookings
  }

  /// Called when the user taps a notification (app was in background or killed)
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM] Notification tapped: ${message.notification?.title}');
      debugPrint('[FCM] Data: ${message.data}');
    }
    // TODO: Navigate to the relevant screen based on message.data
    // e.g. if data['type'] == 'booking_update' -> navigate to booking detail
    // Use a global NavigatorKey or a navigation service for this
  }

  // ---------------------------------------------------------------------------
  // Topic Subscription (optional helper)
  // ---------------------------------------------------------------------------

  /// Subscribe the device to a Firestore topic for broadcast notifications
  /// e.g. subscribeToTopic('all_users') or subscribeToTopic('city_mumbai')
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('[FCM] Subscribed to topic: $topic');
  }

  /// Unsubscribe from a notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('[FCM] Unsubscribed from topic: $topic');
  }
}

/// Background message handler — must be a top-level function (not a class method)
/// Register it in main.dart with FirebaseMessaging.onBackgroundMessage()
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase must be initialised before handling background messages
  // await Firebase.initializeApp(); // Ensure this is called in main.dart first
  debugPrint('[FCM] Background message: ${message.notification?.title}');
  // Handle data-only background messages here
}
