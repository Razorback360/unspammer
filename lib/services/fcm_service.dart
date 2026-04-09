import 'dart:convert' as dart_convert;
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../di/service_locator.dart';
import '../models/calendar_model.dart';
import '../models/email_model.dart';
import 'database_service.dart';
import 'key_service.dart';

// Must be a top-level function — executed in a separate isolate when app is
// terminated or backgrounded.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The background isolate starts with no Flutter binding — initialize it so
  // that platform channels (used by path_provider → Hive, secure_storage,
  // etc.) are available.
  WidgetsFlutterBinding.ensureInitialized();

  // Guard against double-initialization if the isolate happens to be reused.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  await setupDependencies();
  print('Handling a background message: ${message.messageId}');
  if (message.data.isNotEmpty) {
    await FcmService.processDataMessage(message.data);
  }
}

class FcmService {
  /// Initialize FCM handlers. Call this early in your app lifecycle (e.g., in main.dart)
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Received FCM message in foreground: ${message.messageId}');
      if (message.data.isNotEmpty) {
        await processDataMessage(message.data);
      }
    });
  }

  /// Processes the FCM data payload: fetches, decrypts, and stores the email.
  static Future<void> processDataMessage(Map<String, dynamic> data) async {
    try {
      print('Processing FCM data payload: $data');

      final notificationType = data['type'];
      final messageId = data['message_id'];

      if (notificationType == 'new_email' &&
          messageId != null &&
          messageId.isNotEmpty) {
        print('Extracted message ID: $messageId');

        const storage = FlutterSecureStorage();
        final deviceId = await storage.read(key: 'device_id');

        if (deviceId == null || deviceId.isEmpty) {
          print('No device_id found in secure storage. Cannot fetch email.');
          return;
        }

        print(
          'Fetching encrypted email payload for message ID: $messageId from API...',
        );
        final encryptedData = await _fetchEmailFromApi(messageId, deviceId);
        print(
          'Successfully fetched encrypted data length: ${encryptedData.length}',
        );

        print('Decrypting payload using KeyService...');
        final keyService = getIt<KeyService>();
        final decryptedEmail = await keyService.decryptEmail(
          encryptedData['data'],
        );
        print(
          'Successfully decrypted email from: ${decryptedEmail["from_address"]} - Subject: ${decryptedEmail["subject"]}',
        );

        await _storeEmail(decryptedEmail, messageId);

        print('Confirming sync with the backend for message ID: $messageId');
        await _confirmSync(messageId, deviceId);

        print(
          'Successfully completely processed data message sync for email ID: $messageId',
        );
      } else {
        print(
          'Ignored FCM message (not a new_email event or missing message_id). Type: $notificationType',
        );
      }
    } catch (e) {
      print('Error processing FCM data message: $e');
    }
  }

  /// Fetches any unsynced emails from the backend and stores them locally.
  ///
  /// Calls GET /api/emails/sync?device_id=... and decrypts the returned
  /// batch payload. Each email is assigned a stable SHA-256 content ID so
  /// repeated syncs are idempotent. All errors are caught silently.
  static Future<void> syncEmails() async {
    try {
      const storage = FlutterSecureStorage();
      final deviceId = await storage.read(key: 'device_id');

      if (deviceId == null || deviceId.isEmpty) {
        debugPrint('Email sync skipped: no device_id found.');
        return;
      }

      final url = Uri.parse(
        '${AppConfig.apiBaseUrl}/api/emails/sync?device_id=$deviceId',
      );
      final response = await http.get(url);

      if (response.statusCode != 200) {
        debugPrint(
          'Email sync failed: ${response.statusCode} - ${response.body}',
        );
        return;
      }

      final body = json.decode(response.body) as Map;
      final encryptedData = body['data'] as String?;

      if (encryptedData == null || encryptedData.isEmpty) {
        debugPrint('Email sync: empty payload, nothing to do.');
        return;
      }

      final keyService = getIt<KeyService>();
      final emails = await keyService.decryptList(encryptedData);

      if (emails.isEmpty) {
        debugPrint('Email sync: no new emails.');
        return;
      }

      for (final emailData in emails) {
        final map = emailData as Map<String, dynamic>;
        // Stable, duplicate-safe ID derived from content
        final raw = '${map['from_address']}${map['subject']}${map['body']}';
        final id = sha256
            .convert(dart_convert.utf8.encode(raw))
            .toString()
            .substring(0, 24);
        await _storeEmail(map, id);
      }

      debugPrint('Email sync: stored ${emails.length} email(s).');
    } catch (e) {
      debugPrint('Email sync error: $e');
    }
  }

  static Future<Map> _fetchEmailFromApi(
    String messageId,
    String deviceId,
  ) async {
    final url = Uri.parse(
      '${AppConfig.apiBaseUrl}/api/emails/$messageId?device_id=$deviceId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map;
    } else {
      throw Exception(
        'Failed to fetch email: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<void> _confirmSync(String messageId, String deviceId) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/emails/confirm-sync');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: dart_convert.jsonEncode({
        'message_id': messageId,
        'device_id': deviceId,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 204) {
      throw Exception(
        'Failed to confirm sync: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<void> _storeEmail(
    Map<String, dynamic> decryptedEmailData,
    String messageId,
  ) async {
    final eventDateRaw = decryptedEmailData['event_date'] as String?;
    final eventDate = (eventDateRaw != null && eventDateRaw.isNotEmpty)
        ? DateTime.tryParse(eventDateRaw)
        : null;

    final email = EmailModel(
      id: messageId,
      fromAddress: decryptedEmailData['from_address'] as String? ?? 'Unknown',
      body: decryptedEmailData['body'] as String? ?? '',
      subject: decryptedEmailData['subject'] as String? ?? 'No Subject',
      summary: decryptedEmailData['summary'] as String? ?? '',
      classification:
          decryptedEmailData['classification'] as String? ?? 'Unimportant',
      timestamp: DateTime.now(),
      eventDate: eventDate,
      hasEvent: eventDate != null,
    );

    final db = getIt<DatabaseService>();
    await db.insertEmail(email);

    // Auto-create a calendar event for any email that has a timestamp.
    if (eventDate != null) {
      final calendarEvent = CalendarEvent(
        id: 'email_$messageId',
        title: email.subject,
        description: email.summary.isNotEmpty ? email.summary : email.body,
        date: eventDate,
        sourceEmailId: messageId,
      );
      await db.insertEvent(calendarEvent);
      print(
        'Created calendar event for email ID: $messageId on ${eventDate.toIso8601String()}',
      );
    }

    print('Stored email with ID: $messageId');
  }
}
