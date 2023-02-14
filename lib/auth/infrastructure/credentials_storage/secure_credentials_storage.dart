import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart';

import 'package:github_repo_viewer/auth/infrastructure/credentials_storage/credentials_storage.dart';

class SecureCredentialsStorage implements CredentialsStorage {
  final FlutterSecureStorage _storage;

  SecureCredentialsStorage(this._storage);

  static const _kOauth2Credentials = 'oauth2_credentials';

  Credentials? _cachedCredentials;

  @override
  Future<Credentials?> read() async {
    if (_cachedCredentials != null) return _cachedCredentials;
    final json = await _storage.read(key: _kOauth2Credentials);
    if (json == null) return null;

    try {
      return _cachedCredentials = Credentials.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> save(Credentials credentials) {
    _cachedCredentials = credentials;
    return _storage.write(
      key: _kOauth2Credentials,
      value: credentials.toJson(),
    );
  }

  @override
  Future<void> clear() {
    _cachedCredentials = null;
    return _storage.delete(key: _kOauth2Credentials);
  }
}
