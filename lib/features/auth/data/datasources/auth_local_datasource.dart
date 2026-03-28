import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AuthLocalDataSource {
  const AuthLocalDataSource(this._prefs);
  final SharedPreferences _prefs;

  static const _tokenKey     = 'auth_token';
  static const _userTypeKey  = 'auth_user_type';
  static const _userIdKey    = 'auth_user_id';
  static const _userNameKey  = 'auth_user_name';
  static const _userEmailKey = 'auth_user_email';

  Future<void> saveSession({
    required String token,
    required String userType,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    await Future.wait([
      _prefs.setString(_tokenKey, token),
      _prefs.setString(_userTypeKey, userType),
      _prefs.setString(_userIdKey, userId),
      _prefs.setString(_userNameKey, userName),
      _prefs.setString(_userEmailKey, userEmail),
    ]);
  }

  String? getToken()     => _prefs.getString(_tokenKey);
  String? getUserType()  => _prefs.getString(_userTypeKey);
  String? getUserId()    => _prefs.getString(_userIdKey);
  String? getUserName()  => _prefs.getString(_userNameKey);
  String? getUserEmail() => _prefs.getString(_userEmailKey);

  Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_userTypeKey),
      _prefs.remove(_userIdKey),
      _prefs.remove(_userNameKey),
      _prefs.remove(_userEmailKey),
    ]);
  }
}
