import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class SharedPreferencesModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// Keystore-backed storage for sensitive auth material (tokens, clientId).
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
