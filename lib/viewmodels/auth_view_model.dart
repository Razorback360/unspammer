import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authService);

  final AuthService _authService;

  AuthUser? _user;
  bool _isLoading = false;
  String? _error;

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  /// Checks secure storage for a persisted session.
  /// Call once at startup; if true, skip to home.
  Future<bool> checkExistingSession() async {
    return _authService.isLoggedIn();
  }

  /// Runs the full Microsoft OAuth + backend code exchange flow.
  /// Notifies listeners when done. Check [error] for failures.
  Future<void> signIn() async {
    await _runGuarded(() async {
      final code = await _authService.signInWithMicrosoft();
      _user = await _authService.exchangeCode(code);
    });
  }

  Future<void> signOut() async {
    await _runGuarded(() async {
      await _authService.signOut();
      _user = null;
    });
  }

  Future<void> _runGuarded(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await action();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
