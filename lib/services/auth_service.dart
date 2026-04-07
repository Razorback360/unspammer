import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

/// Represents a fully authenticated session (backend oauth_account record).
class AuthUser {
  const AuthUser({
    required this.oauthAccountId,
    required this.deviceId,
    required this.microsoftUserId,
    required this.expiresAt,
  });

  final String oauthAccountId;
  final String deviceId;
  final String microsoftUserId;
  final DateTime expiresAt;
}

class AuthService {
  AuthService()
    : _storage = const FlutterSecureStorage(),
      _appAuth = const FlutterAppAuth();

  final FlutterSecureStorage _storage;
  final FlutterAppAuth _appAuth;

  static const _deviceIdKey = 'device_id';
  static const _oauthAccountIdKey = 'oauth_account_id';

  /// True when this device has been successfully registered with the backend.
  Future<bool> isDeviceRegistered() async {
    final id = await _storage.read(key: _deviceIdKey);
    return id != null && id.isNotEmpty;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// True when an oauth_account_id is already stored (session persists).
  Future<bool> isLoggedIn() async {
    final id = await _storage.read(key: _oauthAccountIdKey);
    return id != null && id.isNotEmpty;
  }

  /// Updates the FCM token and public key for an already-registered device.
  ///
  /// Sends [fcmToken] and [publicKey] to `PUT /api/devices/{device_id}/fcm-token`.
  /// Returns silently on 304 (backend reports nothing changed).
  Future<void> updateDeviceToken({
    required String fcmToken,
    required String publicKey,
  }) async {
    final deviceId = await _storage.read(key: _deviceIdKey);
    if (deviceId == null || deviceId.isEmpty) {
      throw StateError('No device_id found. Call registerDevice() first.');
    }

    final response = await http.put(
      Uri.parse('${AppConfig.apiBaseUrl}/api/devices/$deviceId/fcm-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fcm_token': fcmToken, 'public_key': publicKey}),
    );

    if (response.statusCode == 304) {
      debugPrint('Device token unchanged (304).');
      return;
    }

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Device token update failed (${response.statusCode}): ${response.body}',
      );
    }

    debugPrint('Device token updated for device: $deviceId');
  }

  /// Registers this device with the backend.
  ///
  /// Sends [fcmToken] and [publicKey] to `POST /api/devices/register`.
  /// Stores the returned device UUID as [_deviceIdKey].
  Future<void> registerDevice({
    required String fcmToken,
    required String publicKey,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/devices/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fcm_token': fcmToken, 'public_key': publicKey}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Device registration failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final deviceId = body['id'] as String?;
    if (deviceId == null || deviceId.isEmpty) {
      throw Exception('Backend returned no device id: ${response.body}');
    }

    await _storage.write(key: _deviceIdKey, value: deviceId);
    debugPrint('Device registered, id: $deviceId');
  }

  /// Launches the Microsoft PKCE OAuth flow and returns the auth code.
  ///
  /// Throws if the user cancels or the flow fails.
  Future<List> signInWithMicrosoft() async {
    final result = await _appAuth.authorize(
      AuthorizationRequest(
        AppConfig.microsoftClientId,
        AppConfig.redirectUri,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: AppConfig.authorizationEndpoint,
          tokenEndpoint: AppConfig.tokenEndpoint,
        ),
        scopes: const [
          'offline_access',
          'openid',
          'profile',
          'https://graph.microsoft.com/Mail.Read',
        ],
        promptValues: const ['select_account'],
      ),
    );

    if (result.authorizationCode == null) {
      throw Exception('Microsoft sign-in cancelled or returned no code.');
    }

    return [result.authorizationCode!, result.codeVerifier!];
  }

  /// Exchanges [code] with the backend for an oauth_account record.
  ///
  /// Stores the returned oauth_account UUID and returns the full [AuthUser].
  Future<AuthUser> exchangeCode(List data) async {
    final deviceId = await _storage.read(key: _deviceIdKey);
    if (deviceId == null || deviceId.isEmpty) {
      throw StateError('No device_id found. Call registerDevice() first.');
    }
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/oauth/token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fcm_token_id': deviceId,
        'code': data[0],
        'code_verifier': data[1],
        'redirect_uri': AppConfig.redirectUri,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Token exchange failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final oauthAccountId = body['id'] as String?;
    final microsoftUserId = body['microsoft_user_id'] as String? ?? '';
    final expiresAtStr = body['expires_at'] as String? ?? '';

    if (oauthAccountId == null || oauthAccountId.isEmpty) {
      throw Exception('Backend returned no oauth_account id: ${response.body}');
    }

    await _storage.write(key: _oauthAccountIdKey, value: oauthAccountId);
    debugPrint('OAuth account id saved: $oauthAccountId');

    return AuthUser(
      oauthAccountId: oauthAccountId,
      deviceId: deviceId,
      microsoftUserId: microsoftUserId,
      expiresAt: expiresAtStr.isNotEmpty
          ? DateTime.parse(expiresAtStr)
          : DateTime.now().add(const Duration(hours: 1)),
    );
  }

  /// Clears all stored credentials (logout).
  Future<void> signOut() async {
    await _storage.delete(key: _oauthAccountIdKey);
  }
}
