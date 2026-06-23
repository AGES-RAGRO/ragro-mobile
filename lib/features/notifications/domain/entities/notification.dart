import 'package:equatable/equatable.dart';

class AppNotificationEntity extends Equatable {
  const AppNotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  AppNotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    bool? read,
    DateTime? createdAt,
  }) {
    return AppNotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, message, read, createdAt];
}
