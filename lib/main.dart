import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'di/service_locator.dart';
import 'nav.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/firebase_service.dart';
import 'theme.dart';
import 'viewmodels/auth_view_model.dart';
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
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await setupDependencies();
  await getIt<FirebaseService>().initialize();
  printFCMToken();
  runApp(const MyApp());
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
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthService>())
            ..trySilentSignIn(),
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
