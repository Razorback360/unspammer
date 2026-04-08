import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import 'database_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM background message: ${message.messageId}');

  if (message.notification != null) {
    debugPrint('Received background notification: ${message.notification?.title}');
  }
}

class FirebaseService {
  FirebaseService(this._databaseService);

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DatabaseService _databaseService;

  Future<void> initialize() async {
    await _requestPermissions();
    await _setupInteractedMessageHandling();
    await _subscribeToTopics();
    await _logAndWatchToken();

    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');
  }

  Future<void> _setupInteractedMessageHandling() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _logAndWatchToken() async {
    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');

    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token refreshed: $newToken');
      await _subscribeToTopics();
    });
  }

  Future<void> _subscribeToTopics() async {
    await _messaging.subscribeToTopic('all');
    debugPrint("Subscribed to FCM topic 'all'");
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('Notification opened app: ${message.messageId}');
  }
}


Future<void> printFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String? token = await messaging.getToken();
  print("FCM TOKEN: $token");
}