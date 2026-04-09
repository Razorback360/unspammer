import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unspammer/services/fcm_service.dart';

import 'di/service_locator.dart';
import 'nav.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/firebase_service.dart';
import 'services/key_service.dart';
import 'theme.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/email_view_model.dart';
import 'viewmodels/notification_view_model.dart';

/// Main entry point for the application
///
/// This sets up:
/// - Provider state management (ThemeProvider, CounterProvider)
/// - go_router navigation
/// - Material 3 theming with light/dark modes
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await FcmService.initialize();
  await setupDependencies();
  await getIt<FirebaseService>().initialize();

  // ── First-launch: generate key pair & register device ────────────────────
  await _ensureDeviceRegistered();

  // ── Background email sync — does not block app startup ───────────────────
  unawaited(FcmService.syncEmails());

  runApp(const MyApp());
}

/// Generates an EC key pair on first launch (once, permanent).
/// Registers the device with the backend on every launch until it succeeds
/// — if registration failed previously, device_id won't be stored and we retry.
Future<void> _ensureDeviceRegistered() async {
  final keyService = getIt<KeyService>();
  final authService = getIt<AuthService>();

  // Step 1: generate key pair if not yet done (runs exactly once ever)
  if (!await keyService.hasKeyPair()) {
    await keyService.generateAndStore();
    debugPrint('Key pair generated.');
  }

  // Step 2: register device if not yet registered, or sync token if already registered
  final fcmToken = await FirebaseMessaging.instance.getToken();
  final publicKey = await keyService.getPublicKeyBase64();

  if (fcmToken != null && publicKey != null) {
    if (await authService.isDeviceRegistered()) {
      // Device already known — push latest FCM token + public key to backend
      try {
        await authService.updateDeviceToken(
          fcmToken: fcmToken,
          publicKey: publicKey,
        );
      } catch (e) {
        debugPrint('Device token update error: $e');
      }
    } else {
      // First time (or previous registration failed) — register with backend
      try {
        await authService.registerDevice(
          fcmToken: fcmToken,
          publicKey: publicKey,
        );
      } catch (e) {
        debugPrint('Device registration error (will retry next launch): $e');
      }
    }
  } else {
    debugPrint(
      'Skipping device registration/update: FCM token or public key missing.',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: getIt<DatabaseService>()),
        Provider<AuthService>.value(value: getIt<AuthService>()),
        ChangeNotifierProvider<NotificationViewModel>(
          create: (context) =>
              NotificationViewModel(context.read<DatabaseService>()),
        ),
        ChangeNotifierProvider<EmailViewModel>(
          create: (context) => EmailViewModel(context.read<DatabaseService>()),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthService>()),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppColors.themeModeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp.router(
            title: 'Unspammer',
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,

            // Use context.go() or context.push() to navigate to the routes.
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
