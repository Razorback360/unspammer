import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authService);

  final AuthService _authService;

  AuthUser? _user;
  bool _isLoading = false;
  String? _error;
  List<GmailMessageMetadata> _gmailPreview = const <GmailMessageMetadata>[];

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<GmailMessageMetadata> get gmailPreview => _gmailPreview;

  Future<void> signIn() async {
    await _runGuarded(() async {
      _user = await _authService.signIn();
    });
  }

  Future<void> trySilentSignIn() async {
    await _runGuarded(() async {
      _user = await _authService.signInSilently();
    });
  }

  Future<void> signOut() async {
    await _runGuarded(() async {
      await _authService.signOut();
      _user = null;
      _gmailPreview = const <GmailMessageMetadata>[];
    });
  }

  Future<void> loadGmailPreview() async {
    await _runGuarded(() async {
      _gmailPreview = await _authService.fetchRecentGmailMetadata(maxResults: 5);
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

