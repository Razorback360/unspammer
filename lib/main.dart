import 'package:flutter/material.dart';

import 'nav.dart';
import 'theme.dart';

/// Main entry point for the application
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
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
    );
  }
}
