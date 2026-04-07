import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/database_service.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel(this._databaseService) {
    _subscription = _databaseService.watchAll().listen((items) {
      _notifications = items;
      notifyListeners();
    });
  }

  final DatabaseService _databaseService;
  late final StreamSubscription<List<NotificationModel>> _subscription;

  List<NotificationModel> _notifications = const <NotificationModel>[];
  List<NotificationModel> get notifications => _notifications;

  Future<void> refresh() async {
    _notifications = await _databaseService.fetchAll();
    notifyListeners();
  }

  Future<void> remove(String id) => _databaseService.delete(id);

  Future<void> markAsImportant({
    required String id,
    required bool isImportant,
  }) {
    return _databaseService.markAsImportant(id: id, isImportant: isImportant);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

