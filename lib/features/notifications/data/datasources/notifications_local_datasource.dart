import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/notifications/data/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local cache for notifications (offline-friendly display).
///
/// The backend REST API stays the source of truth — this is a best-effort
/// mirror of the last successful fetch, persisted in [SharedPreferences].
@lazySingleton
class NotificationsLocalDataSource {
  const NotificationsLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _listKey = 'notifications_cache_v1';
  static const _countKey = 'notifications_unread_count_v1';

  Future<void> cacheNotifications(
    List<AppNotificationModel> notifications,
  ) async {
    final jsonList = notifications.map((n) => n.toJson()).toList();
    await _prefs.setString(_listKey, jsonEncode(jsonList));
  }

  List<AppNotificationModel> getCachedNotifications() {
    final raw = _prefs.getString(_listKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(AppNotificationModel.fromJson)
          .toList();
    } on FormatException {
      return const [];
    }
  }

  Future<void> cacheUnreadCount(int count) async {
    await _prefs.setInt(_countKey, count);
  }

  int getCachedUnreadCount() => _prefs.getInt(_countKey) ?? 0;

  Future<void> markCachedAsRead(String id) async {
    final raw = _prefs.getString(_listKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return;
    var changed = false;
    for (final item in decoded) {
      if (item is Map<String, dynamic> &&
          item['id'].toString() == id &&
          item['read'] != true) {
        item['read'] = true;
        changed = true;
      }
    }
    if (!changed) return;
    await _prefs.setString(_listKey, jsonEncode(decoded));
    final count = getCachedUnreadCount();
    if (count > 0) await cacheUnreadCount(count - 1);
  }

  Future<void> markAllCachedAsRead() async {
    final raw = _prefs.getString(_listKey);
    if (raw != null) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) item['read'] = true;
        }
        await _prefs.setString(_listKey, jsonEncode(decoded));
      }
    }
    await cacheUnreadCount(0);
  }

  Future<void> clear() async {
    await _prefs.remove(_listKey);
    await _prefs.remove(_countKey);
  }
}
