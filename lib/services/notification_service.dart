// services/notification_service.dart

// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'backend_service.dart';

// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp();

  // Process background message and show local notification
  print("Handling a background message: ${message.messageId}");

  // Use the NotificationService instance to show the background notification
  NotificationService()._showBackgroundNotification(message);
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final BackendService _backendService = BackendService();

  Future<void> initialize() async {
    // Set up background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true, // Important for medical alerts
      provisional: false,
      sound: true,
    );

    // Create high priority Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'seizure_alerts',
      'Seizure Alerts',
      description: 'Notifications for seizure alerts',
      importance: Importance.max,
      enableVibration: true,
      showBadge: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alert_sound'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Configure local notifications
    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        if (details.payload != null) {
          print('Notification tapped with payload: ${details.payload}');
          // Navigate to specific screen if needed
        }
      },
    );

    // Handle FCM messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Save FCM token to backend
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToBackend(token);
    }

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen(_saveTokenToBackend);
  }

  Future<void> _saveTokenToBackend(String token) async {
    await _backendService.updateFcmToken(token);
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Seizure Alert',
        notification.body ?? 'Please check the app for details',
        NotificationDetails(
          android: AndroidNotificationDetails(
              'seizure_alerts', 'Seizure Alerts',
              importance: Importance.max,
              priority: Priority.high,
              sound: RawResourceAndroidNotificationSound('alert_sound'),
              fullScreenIntent: true,
              ticker: 'ticker',
              icon: android.smallIcon),
        ),
        payload: message.data['probability'],
      );
    }
  }

  // Handle background notifications (custom sound)
  void _showBackgroundNotification(RemoteMessage message) async {
    FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Seizure Alert',
        notification.body ?? 'Please check the app for details',
        NotificationDetails(
          android: AndroidNotificationDetails(
              'seizure_alerts', 'Seizure Alerts',
              importance: Importance.max,
              priority: Priority.high,
              sound: RawResourceAndroidNotificationSound('alert_sound'),
              fullScreenIntent: true,
              ticker: 'ticker',
              icon: android.smallIcon),
        ),
        payload: message.data['probability'],
      );
    }
  }
}
