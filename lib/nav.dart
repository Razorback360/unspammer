import 'package:go_router/go_router.dart';

import 'di/service_locator.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'services/auth_service.dart';

/// GoRouter configuration for app navigation
///
/// This uses go_router for declarative routing, which provides:
/// - Type-safe navigation
/// - Deep linking support (web URLs, app links)
/// - Easy route parameters
/// - Navigation guards and redirects
///
/// To add a new route:
/// 1. Add a route constant to AppRoutes below
/// 2. Add a GoRoute to the routes list
/// 3. Navigate using context.go() or context.push()
/// 4. Use context.pop() to go back.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) async {
      final loggedIn = await getIt<AuthService>().isLoggedIn();
      final goingToLogin = state.matchedLocation == AppRoutes.login;

      // Already authenticated → skip login and go straight to home
      if (loggedIn && goingToLogin) return AppRoutes.home;

      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomePage()),
      ),
    ],
  );
}

/// Route path constants
/// Use these instead of hard-coding route strings
class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
}
