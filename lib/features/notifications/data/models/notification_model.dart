import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';

class AppNotificationModel extends AppNotificationEntity {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.read,
    required super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      message:
          json['message'] as String? ??
          json['body'] as String? ??
          json['description'] as String? ??
          '',
      read: _parseRead(json),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  static bool _parseRead(Map<String, dynamic> json) {
    for (final key in const ['read', 'isRead', 'is_read', 'visualized']) {
      final value = json[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase().trim();
        if (normalized == 'true' || normalized == '1') return true;
        if (normalized == 'false' || normalized == '0') return false;
      }
    }

    final readAt = json['readAt'] ?? json['read_at'];
    return readAt != null && readAt.toString().trim().isNotEmpty;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value.toLocal();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }
}
