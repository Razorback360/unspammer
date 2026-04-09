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

  final _algo = X25519();

  /// Shared decryption core — returns the raw decoded JSON value.
  Future<dynamic> _decryptRaw(String encryptedBase64) async {
    final envelope =
        jsonDecode(utf8.decode(base64Decode(encryptedBase64)))
            as Map<String, dynamic>;

    final privateKeyBytes = base64Decode(
      (await _storage.read(key: _privateKeyKey))!,
    );
    final publicKeyBytes = base64Decode(
      (await _storage.read(key: _publicKeyKey))!,
    );

    final keyPair = SimpleKeyPairData(
      privateKeyBytes,
      publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519),
      type: KeyPairType.x25519,
    );

    final ephemeralPublicKey = SimplePublicKey(
      base64Decode(envelope['ephemeral_public'] as String),
      type: KeyPairType.x25519,
    );

    final x25519 = X25519();
    final sharedSecret = await x25519.sharedSecretKey(
      keyPair: keyPair,
      remotePublicKey: ephemeralPublicKey,
    );

    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final aesKey = await hkdf.deriveKey(
      secretKey: sharedSecret,
      info: utf8.encode('email-encryption'),
    );

    final nonce = base64Decode(envelope['nonce'] as String);
    final ciphertext = base64Decode(envelope['ciphertext'] as String);
    final tag = base64Decode(envelope['tag'] as String);

    final aesGcm = AesGcm.with256bits();
    final plaintext = await aesGcm.decrypt(
      SecretBox(ciphertext, nonce: nonce, mac: Mac(tag)),
      secretKey: aesKey,
    );

    return jsonDecode(utf8.decode(plaintext));
  }

  /// Decrypts an encrypted base64 payload into a single email map.
  Future<Map<String, dynamic>> decryptEmail(String encryptedBase64) async {
    return (await _decryptRaw(encryptedBase64)) as Map<String, dynamic>;
  }

  /// Decrypts an encrypted base64 payload that contains a list of emails.
  Future<List<dynamic>> decryptList(String encryptedBase64) async {
    return (await _decryptRaw(encryptedBase64)) as List<dynamic>;
  }

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
