import 'package:hive_flutter/hive_flutter.dart';

import '../models/notification_model.dart';
import '../models/email_model.dart';

class DatabaseService {
  static const String _notificationsBox = 'notifications_box';
  static const String _emailsBox = 'emails_box';

  late final Box<Map> _box;
  late final Box<Map> _emailsStorageBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_notificationsBox);
    _emailsStorageBox = await Hive.openBox<Map>(_emailsBox);
  }

  // --- Notifications ---
  Future<void> insert(NotificationModel notification) async {
    await _box.put(notification.id, notification.toMap());
  }

  Future<List<NotificationModel>> fetchAll() async {
    return _toSortedList(_box.values);
  }

  Stream<List<NotificationModel>> watchAll() {
    return _box.watch().map((_) => _toSortedList(_box.values)).startWith(
          _toSortedList(_box.values),
        );
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> markAsImportant({
    required String id,
    required bool isImportant,
  }) async {
    final existing = _box.get(id);
    if (existing == null) return;

    final current = NotificationModel.fromMap(existing);
    await _box.put(id, current.copyWith(isImportant: isImportant).toMap());
  }

  List<NotificationModel> _toSortedList(Iterable<Map> values) {
    final list = values
        .map((e) => NotificationModel.fromMap(e))
        .toList(growable: false);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  // --- Emails ---
  Future<void> insertEmail(EmailModel email) async {
    await _emailsStorageBox.put(email.id, email.toMap());
  }

  Future<List<EmailModel>> fetchAllEmails() async {
    return _toSortedEmailsList(_emailsStorageBox.toMap());
  }

  Stream<List<EmailModel>> watchAllEmails() {
    return _emailsStorageBox.watch().map((_) => _toSortedEmailsList(_emailsStorageBox.toMap())).startWith(
          _toSortedEmailsList(_emailsStorageBox.toMap()),
        );
  }

  Future<void> deleteEmail(String id) async {
    await _emailsStorageBox.delete(id);
  }

  List<EmailModel> _toSortedEmailsList(Map<dynamic, dynamic> mapEntries) {
    final list = mapEntries.entries
        .map((e) => EmailModel.fromMap(e.value as Map<dynamic, dynamic>, e.key as String))
        .toList(growable: false);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }
}

extension _SeededStream<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
