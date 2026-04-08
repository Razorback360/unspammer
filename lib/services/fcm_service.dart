import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert' as dart_convert;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import 'key_service.dart';
import 'database_service.dart';
import '../models/email_model.dart';

// This must be a top-level function to handle background messages when the app is terminated or in the background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase in the background isolate
  await Firebase.initializeApp();

  print('Handling a background message: ${message.messageId}');
  if (message.data.isNotEmpty) {
    await FcmService.processDataMessage(message.data);
  }
}

class FcmService {
  /// Initialize FCM handlers. Call this early in your app lifecycle (e.g., in main.dart)
  static Future<void> initialize() async {
    // Set up the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Processes the FCM data payload: fetches, decrypts, and stores the email.
  static Future<void> processDataMessage(Map<String, dynamic> data) async {
    try {
      // 1. Parse the incoming data structure
      print('Processing FCM data payload: $data');

      final notificationType = data['type'];
      final messageId = data['message_id'];

      if (notificationType == 'new_email' && messageId != null && messageId.isNotEmpty) {
        print('Extracted message ID: $messageId');

        // Retrieve the device_id from secure storage (saved by AuthService during registration)
        const storage = FlutterSecureStorage();
        final deviceId = await storage.read(key: 'device_id');

        if (deviceId == null || deviceId.isEmpty) {
          print('No device_id found in secure storage. Cannot fetch email.');
          return;
        }

        print('Fetching encrypted email payload for message ID: $messageId from API...');
        // 2. Fetch the encrypted email from API
        final encryptedData = await _fetchEmailFromApi(messageId, deviceId);
        print('Successfully fetched encrypted data length: ${encryptedData.length}');

        print('Decrypting payload using KeyService...');
        // 3. Decrypt the fetched email using KeyService
        final keyService = KeyService();
        final decryptedEmail = await keyService.decryptEmail(encryptedData['data']);
        print('Successfully decrypted email from: ${decryptedEmail["from_address"]} - Subject: ${decryptedEmail["subject"]}');

        // 4. Store the decrypted email
        await _storeEmail(decryptedEmail, messageId);

        print('Confirming sync with the backend for message ID: $messageId');
        // 5. Confirm sync with the backend
        await _confirmSync(messageId, deviceId);

        print('Successfully completely processed data message sync for email ID: $messageId');
      } else {
        print('Ignored FCM message (not a new_email event or missing message_id). Type: $notificationType');
      }
    } catch (e) {
      print('Error processing FCM data message: $e');
    }
  }

  // --- Placeholder methods to be implemented --- //

  static Future<Map> _fetchEmailFromApi(String messageId, String deviceId) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/emails/$messageId?device_id=$deviceId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // The API returns a base64-encoded single string containing the JSON
      return json.decode(response.body) as Map;
    } else {
      throw Exception('Failed to fetch email: ${response.statusCode} - ${response.body}');
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
      throw Exception('Failed to confirm sync: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> _storeEmail(Map<String, dynamic> decryptedEmailData, String messageId) async {
    final email = EmailModel(
      id: messageId,
      fromAddress: decryptedEmailData['from_address'] as String? ?? 'Unknown',
      body: decryptedEmailData['body'] as String? ?? '',
      subject: decryptedEmailData['subject'] as String? ?? 'No Subject',
      summary: decryptedEmailData['summary'] as String? ?? '',
      classification: decryptedEmailData['classification'] as String? ?? 'not_important',
      timestamp: DateTime.now(),
    );

    // If using GetIt:
    // final db = getIt<DatabaseService>();
    // await db.insertEmail(email);

    // As a standalone safe-fallback for background handler without getIt:
    final db = DatabaseService();
    await db.init(); // Initialize database if it hasn't been already in this isolate
    await db.insertEmail(email);

    print('Stored email with ID: $messageId');
  }
}
