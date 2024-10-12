import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MessagingService {
  static String? fcmToken; // Variable to store the FCM token

  static final MessagingService _instance = MessagingService._internal();

  factory MessagingService() => _instance;

  MessagingService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init(BuildContext context) async {
    // Requesting permission for notifications
    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted notifications permission: ${settings.authorizationStatus}');
    Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
      await Firebase.initializeApp();
      print("Handling a background message: ${message.messageId}");
      print(message.data);
    }
    // Retrieving the FCM token
    fcmToken = await _fcm.getToken();
    log('fcmToken: $fcmToken');

    // Handling background messages using the specified handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Listening for incoming messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.notification?.title}');

      if (message.notification != null) {
        if (message.notification!.title != null && message.notification!.body != null) {
          final Map<String, dynamic> notificationData = message.data;
          final String? screen = notificationData['screen'];

          // Showing an alert dialog when a notification is received (Foreground state)
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  title: Text(message.notification!.title!),
                  content: Text(message.notification!.body!),
                  actions: [
                    if (screen != null)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(screen);
                        },
                        child: const Text('Open Screen'),
                      ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              );
            },
          );
        }
      }
    });

    // Handling the initial message received when the app is launched from dead (killed state)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationClick(context, message);
      }
    });

    // Handling a notification click event when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('onMessageOpenedApp: ${message.notification?.title}');
      _handleNotificationClick(context, message);
    });
  }

  void _handleNotificationClick(BuildContext context, RemoteMessage message) {
    final Map<String, dynamic> notificationData = message.data;

    if (notificationData.containsKey('screen')) {
      final String screen = notificationData['screen'];
      Navigator.of(context).pushNamed(screen);
    }
  }
}
