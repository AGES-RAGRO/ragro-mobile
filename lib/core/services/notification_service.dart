import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';

@lazySingleton
class NotificationService {
  NotificationService(this._apiClient);

  final ApiClient _apiClient;
  final _messaging = FirebaseMessaging.instance;

  /// Call at app startup — only asks for OS permission, no network call.
  Future<void> requestPermission() async {
    await _messaging.requestPermission();
  }

  /// Call after the user is authenticated — registers the FCM token with the
  /// backend and keeps it fresh whenever Firebase rotates it.
  Future<void> registerToken() async {
    final settings = await _messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await _messaging.getToken();
    if (token != null) await _sendToken(token);

    _messaging.onTokenRefresh.listen(_sendToken);

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] foreground: ${message.notification?.title}');
    });
  }

  Future<void> _sendToken(String token) async {
    try {
      await _apiClient.dio.post<void>(
        ApiEndpoints.fcmToken,
        data: {'token': token},
      );
    } on Exception catch (e) {
      debugPrint('[FCM] failed to register token: $e');
    }
  }
}
