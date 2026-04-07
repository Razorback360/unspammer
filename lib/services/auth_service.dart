import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthUser {
  const AuthUser({
    required this.email,
    required this.accessToken,
  });

  final String email;
  final String accessToken;
}

class GmailMessageMetadata {
  const GmailMessageMetadata({
    required this.id,
    required this.subject,
    required this.sender,
  });

  final String id;
  final String subject;
  final String sender;
}

class AuthService {
  AuthService()
    : _googleSignIn = GoogleSignIn(
        scopes: const <String>[
          'email',
          'https://www.googleapis.com/auth/gmail.readonly',
        ],
      );

  final GoogleSignIn _googleSignIn;

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<AuthUser?> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final accessToken = await _resolveAccessToken(account);
    if (accessToken == null) return null;

    return AuthUser(email: account.email, accessToken: accessToken);
  }

  Future<AuthUser?> signInSilently() async {
    final account = await _googleSignIn.signInSilently();
    if (account == null) return null;

    final accessToken = await _resolveAccessToken(account);
    if (accessToken == null) return null;

    return AuthUser(email: account.email, accessToken: accessToken);
  }

  Future<void> signOut() => _googleSignIn.signOut();

  Future<String?> getValidAccessToken() async {
    final account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (account == null) return null;

    // google_sign_in refreshes token under the hood when needed.
    return _resolveAccessToken(account);
  }

  Future<List<GmailMessageMetadata>> fetchRecentGmailMetadata({
    int maxResults = 10,
  }) async {
    final token = await getValidAccessToken();
    if (token == null) {
      throw StateError('No access token. User must sign in first.');
    }

    final listResponse = await http.get(
      Uri.parse(
        'https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=$maxResults',
      ),
      headers: _authHeaders(token),
    );

    if (listResponse.statusCode != 200) {
      throw Exception('Failed to fetch Gmail message list: ${listResponse.body}');
    }

    final listJson = jsonDecode(listResponse.body) as Map<String, dynamic>;
    final messages =
        (listJson['messages'] as List<dynamic>? ?? const <dynamic>[])
            .cast<Map<String, dynamic>>();

    final metadata = <GmailMessageMetadata>[];

    for (final item in messages) {
      final id = item['id'] as String?;
      if (id == null) continue;

      final detailsResponse = await http.get(
        Uri.parse(
          'https://gmail.googleapis.com/gmail/v1/users/me/messages/$id?format=metadata&metadataHeaders=Subject&metadataHeaders=From',
        ),
        headers: _authHeaders(token),
      );

      if (detailsResponse.statusCode != 200) {
        debugPrint('Gmail metadata fetch skipped for $id: ${detailsResponse.body}');
        continue;
      }

      final detailsJson = jsonDecode(detailsResponse.body) as Map<String, dynamic>;
      final payload = detailsJson['payload'] as Map<String, dynamic>?;
      final headers =
          (payload?['headers'] as List<dynamic>? ?? const <dynamic>[])
              .cast<Map<String, dynamic>>();

      String subject = '';
      String sender = '';

      for (final header in headers) {
        final name = (header['name'] as String? ?? '').toLowerCase();
        final value = header['value'] as String? ?? '';
        if (name == 'subject') subject = value;
        if (name == 'from') sender = value;
      }

      metadata.add(
        GmailMessageMetadata(id: id, subject: subject, sender: sender),
      );
    }

    return metadata;
  }

  Future<String?> _resolveAccessToken(GoogleSignInAccount account) async {
    final auth = await account.authentication;
    return auth.accessToken;
  }

  Map<String, String> _authHeaders(String token) {
    return <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }
}

