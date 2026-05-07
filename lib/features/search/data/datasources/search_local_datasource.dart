import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SearchLocalDataSource {
  const SearchLocalDataSource(this._prefs);
  final SharedPreferences _prefs;

  static const _recentSearchesKey = 'search_recent_searches';
  static const _maxRecent = 10;

  List<String> getRecentSearches() {
    final json = _prefs.getString(_recentSearchesKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.cast<String>();
    } on Exception {
      return [];
    }
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final current = [
      trimmed,
      ...getRecentSearches().where((q) => q != trimmed),
    ];
    if (current.length > _maxRecent) {
      current.removeRange(_maxRecent, current.length);
    }
    await _prefs.setString(_recentSearchesKey, jsonEncode(current));
  }

  Future<void> removeRecentSearch(String query) async {
    final current = getRecentSearches().where((q) => q != query).toList();
    await _prefs.setString(_recentSearchesKey, jsonEncode(current));
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(_recentSearchesKey);
  }
}
