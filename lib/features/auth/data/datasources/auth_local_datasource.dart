import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the auth session. Sensitive material (access/refresh tokens, token URL and clientId)
/// lives in Keystore-backed [FlutterSecureStorage] — never in plaintext SharedPreferences — while
/// non-sensitive profile fields (type/id/name/email/phone/active) stay in SharedPreferences for
/// cheap synchronous reads.
@lazySingleton
class AuthLocalDataSource {
  const AuthLocalDataSource(this._prefs, this._secure);
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  // Secure (Keystore) keys.
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _tokenUrlKey = 'auth_token_url';
  static const _clientIdKey = 'auth_client_id';

  // Non-sensitive profile keys (SharedPreferences).
  static const _userTypeKey = 'auth_user_type';
  static const _userIdKey = 'auth_user_id';
  static const _userNameKey = 'auth_user_name';
  static const _userEmailKey = 'auth_user_email';
  static const _userPhoneKey = 'auth_user_phone';
  static const _userActiveKey = 'auth_user_active';

  Future<void> saveSession({
    required String token,
    required String refreshToken,
    required String tokenUrl,
    required String clientId,
    required String userType,
    required String userId,
    required String userName,
    required String userEmail,
    required bool active,
    String? phone,
  }) async {
    await Future.wait([
      _secure.write(key: _tokenKey, value: token),
      _secure.write(key: _refreshTokenKey, value: refreshToken),
      _secure.write(key: _tokenUrlKey, value: tokenUrl),
      _secure.write(key: _clientIdKey, value: clientId),
    ]);

    final futures = <Future<bool>>[
      _prefs.setString(_userTypeKey, userType),
      _prefs.setString(_userIdKey, userId),
      _prefs.setString(_userNameKey, userName),
      _prefs.setString(_userEmailKey, userEmail),
      _prefs.setBool(_userActiveKey, active),
    ];
    if (phone != null) {
      futures.add(_prefs.setString(_userPhoneKey, phone));
    } else {
      futures.add(_prefs.remove(_userPhoneKey).then((_) => true));
    }
    await Future.wait(futures);
  }

  Future<String?> getToken() => _secure.read(key: _tokenKey);
  Future<String?> getRefreshToken() => _secure.read(key: _refreshTokenKey);
  Future<String?> getTokenUrl() => _secure.read(key: _tokenUrlKey);
  Future<String?> getClientId() => _secure.read(key: _clientIdKey);

  String? getUserType() => _prefs.getString(_userTypeKey);
  String? getUserId() => _prefs.getString(_userIdKey);
  String? getUserName() => _prefs.getString(_userNameKey);
  String? getUserEmail() => _prefs.getString(_userEmailKey);
  String? getUserPhone() => _prefs.getString(_userPhoneKey);
  bool? getUserActive() => _prefs.getBool(_userActiveKey);

  Future<void> clearSession() async {
    await Future.wait([
      _secure.delete(key: _tokenKey),
      _secure.delete(key: _refreshTokenKey),
      _secure.delete(key: _tokenUrlKey),
      _secure.delete(key: _clientIdKey),
      _prefs.remove(_userTypeKey),
      _prefs.remove(_userIdKey),
      _prefs.remove(_userNameKey),
      _prefs.remove(_userEmailKey),
      _prefs.remove(_userPhoneKey),
      _prefs.remove(_userActiveKey),
    ]);
  }
}
