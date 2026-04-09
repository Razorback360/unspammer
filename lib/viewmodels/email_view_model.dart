import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/email_model.dart';
import '../services/database_service.dart';
import '../services/fcm_service.dart';

class EmailViewModel extends ChangeNotifier {
  EmailViewModel(this._databaseService) {
    _subscription = _databaseService.watchAllEmails().listen((items) {
      _emails = items;
      notifyListeners();
    });
  }

  final DatabaseService _databaseService;
  late final StreamSubscription<List<EmailModel>> _subscription;

  List<EmailModel> _emails = const <EmailModel>[];
  List<EmailModel> get emails => _emails;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Fetches unsynced emails from the backend and updates local storage.
  /// The Hive watch stream automatically pushes the new emails to [emails].
  Future<void> syncFromServer() async {
    _isSyncing = true;
    notifyListeners();
    try {
      await FcmService.syncEmails();
    } catch (e) {
      debugPrint('EmailViewModel.syncFromServer error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _emails = await _databaseService.fetchAllEmails();
    notifyListeners();
  }

  Future<void> deleteEmail(String id) => _databaseService.deleteEmail(id);

  Future<void> toggleImportant(EmailModel email) {
    return _databaseService.markEmailAsImportant(
      id: email.id,
      isImportant: !email.isImportant,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
