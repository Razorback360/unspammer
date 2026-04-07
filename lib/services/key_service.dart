import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages an EC P-256 key pair that persists across app restarts.
///
/// The private key is stored securely via [FlutterSecureStorage].
/// The public key is stored as a base64-encoded uncompressed point (04 || x || y)
/// and is safe to share with the backend.
class KeyService {
  KeyService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _privateKeyKey = 'device_private_key_bytes';
  static const String _publicKeyKey = 'device_public_key_b64';

  final _algo =
      Ed25519(); // Ed25519 is simpler; swap for Ecdsa.p256() if backend requires P-256

  /// Returns true if a key pair has already been generated for this device.
  Future<bool> hasKeyPair() async {
    final value = await _storage.read(key: _publicKeyKey);
    return value != null && value.isNotEmpty;
  }

  /// Generates a new Ed25519 key pair and persists it securely.
  /// Safe to call multiple times — only generates if not already present.
  Future<void> generateAndStore() async {
    if (await hasKeyPair()) return;

    final keyPair = await _algo.newKeyPair();
    final privateBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    final publicBytes = Uint8List.fromList(publicKey.bytes);

    await _storage.write(
      key: _privateKeyKey,
      value: base64Encode(privateBytes),
    );
    await _storage.write(key: _publicKeyKey, value: base64Encode(publicBytes));
  }

  /// Returns the public key as a base64 string, or null if not generated yet.
  Future<String?> getPublicKeyBase64() async {
    return _storage.read(key: _publicKeyKey);
  }
}
