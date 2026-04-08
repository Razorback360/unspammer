import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// App-wide configuration constants.
/// Fill in your Microsoft Azure AD credentials and API base URL here.
class AppConfig {
  AppConfig._();

  // ── Backend ──────────────────────────────────────────────────────────────
  static const String apiBaseUrl = 'http://5.189.174.123:8000';

  // ── Microsoft OAuth (Azure AD) ────────────────────────────────────────────
  static const String microsoftClientId =
      '4c65d54a-0fce-45b1-a8f1-5ae8e5a6104d';
  static const String microsoftTenantId = 'common';

  // Redirect URI — must match AndroidManifest intent-filter & iOS URL scheme
  static const String redirectUri = 'unspammer://callback';

  // ── Derived OAuth endpoints ───────────────────────────────────────────────
  static String get authorizationEndpoint =>
      'https://login.microsoftonline.com/$microsoftTenantId/oauth2/v2.0/authorize';

  static String get tokenEndpoint =>
      'https://login.microsoftonline.com/$microsoftTenantId/oauth2/v2.0/token';
}

String generateCodeVerifier() {
  final random = Random.secure();
  final values = List<int>.generate(64, (_) => random.nextInt(256));
  return base64UrlEncode(values).replaceAll('=', '');
}

String generateCodeChallenge(String verifier) {
  final bytes = ascii.encode(verifier);
  final digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes).replaceAll('=', '');
}
