import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AuthLocalDataSource {
  const AuthLocalDataSource(this._prefs);
  final SharedPreferences _prefs;

  static const _tokenKey        = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _tokenUrlKey     = 'auth_token_url';
  static const _clientIdKey     = 'auth_client_id';
  static const _userTypeKey     = 'auth_user_type';
  static const _userIdKey       = 'auth_user_id';
  static const _userNameKey     = 'auth_user_name';
  static const _userEmailKey    = 'auth_user_email';
  static const _userPhoneKey    = 'auth_user_phone';
  static const _userActiveKey   = 'auth_user_active';

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
    final futures = <Future<bool>>[
      _prefs.setString(_tokenKey, token),
      _prefs.setString(_refreshTokenKey, refreshToken),
      _prefs.setString(_tokenUrlKey, tokenUrl),
      _prefs.setString(_clientIdKey, clientId),
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

  String? getToken()        => _prefs.getString(_tokenKey);
  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);
  String? getTokenUrl()     => _prefs.getString(_tokenUrlKey);
  String? getClientId()     => _prefs.getString(_clientIdKey);
  String? getUserType()     => _prefs.getString(_userTypeKey);
  String? getUserId()       => _prefs.getString(_userIdKey);
  String? getUserName()     => _prefs.getString(_userNameKey);
  String? getUserEmail()    => _prefs.getString(_userEmailKey);
  String? getUserPhone()    => _prefs.getString(_userPhoneKey);
  bool?   getUserActive()   => _prefs.getBool(_userActiveKey);

  Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_refreshTokenKey),
      _prefs.remove(_tokenUrlKey),
      _prefs.remove(_clientIdKey),
      _prefs.remove(_userTypeKey),
      _prefs.remove(_userIdKey),
      _prefs.remove(_userNameKey),
      _prefs.remove(_userEmailKey),
      _prefs.remove(_userPhoneKey),
      _prefs.remove(_userActiveKey),
    ]);
  }
}
