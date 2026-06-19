import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/logging/app_logger.dart';
import 'package:ragro_mobile/core/router/app_router.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/notifications/data/datasources/fcm_token_remote_datasource.dart';
import 'package:ragro_mobile/features/notifications/domain/notification_deep_link.dart';

/// Android channel used for foreground heads-up notifications. Must match the
/// `default_notification_channel_id` meta-data in AndroidManifest so OS-rendered
/// (background/terminated) notifications land on the same high-importance channel.
const _androidChannel = AndroidNotificationChannel(
  'ragro_high_importance',
  'Notificações RAGRO',
  description: 'Pedidos e atualizações importantes',
  importance: Importance.high,
);

/// Dedicated FCM orchestrator. Owns init, permissions, the Android channel, the
/// foreground/background/terminated handlers, deep-link navigation and device
/// token registration. No FCM logic lives in widgets.
///
/// Safe to call without Firebase config: if `Firebase.initializeApp()` did not
/// succeed (e.g. missing `google-services.json`), [initialize] no-ops so the rest
/// of the app keeps working.
@lazySingleton
class NotificationService {
  NotificationService(
    this._tokenDataSource,
    this._authLocal,
    this._router,
    this._logger,
  );

  final FcmTokenRemoteDataSource _tokenDataSource;
  final AuthLocalDataSource _authLocal;
  final AppRouter _router;
  final AppLogger _logger;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<void> _onForeground = StreamController<void>.broadcast();

  /// Emits whenever a push arrives while the app is in the foreground, so the
  /// app can refresh the unread badge from the backend (source of truth).
  Stream<void> get onForegroundMessage => _onForeground.stream;

  bool _initialized = false;
  final Set<String> _handledMessageIds = <String>{};
  final List<StreamSubscription<dynamic>> _subs = [];

  Future<void> initialize() async {
    if (_initialized) return;
    if (Firebase.apps.isEmpty) {
      _logger.warn('Firebase não inicializado; FCM desabilitado.');
      return;
    }
    _initialized = true;

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      await _setupLocalNotifications();

      _subs
        ..add(FirebaseMessaging.onMessage.listen(_onForegroundReceived))
        ..add(FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage));

      final initial = await messaging.getInitialMessage();
      if (initial != null) _handleMessage(initial);

      await _registerToken(await messaging.getToken());
      _subs.add(messaging.onTokenRefresh.listen(_registerToken));
      _logger.info('FCM inicializado.');
    } on Object catch (e, st) {
      _logger.error('Falha ao inicializar FCM', error: e, stackTrace: st);
    }
  }

  Future<void> _setupLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _navigateFromData(_decodePayload(payload), messageId: payload);
        }
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  /// Foreground: the OS does NOT auto-display, so we show a heads-up local
  /// notification and signal the app to refresh the badge.
  void _onForegroundReceived(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      unawaited(_localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      ));
    }
    _onForeground.add(null);
  }

  /// Tap on a notification that opened the app (background/terminated).
  void _handleMessage(RemoteMessage message) {
    _navigateFromData(message.data, messageId: message.messageId);
  }

  void _navigateFromData(Map<String, dynamic> data, {String? messageId}) {
    // Idempotency: never act on the same message twice (e.g. getInitialMessage
    // + onMessageOpenedApp, or a re-delivered tap).
    final id = messageId ?? jsonEncode(data);
    if (!_handledMessageIds.add(id)) return;

    final type = _authLocal.getUserType();
    final isProducer = type == 'producer' || type == 'farmer';
    final route = NotificationDeepLink.resolveRoute(
      data: data,
      isProducer: isProducer,
    );
    if (route != null) {
      _logger.info('Deep-link de notificação → $route');
      unawaited(_router.router.push(route));
    }
  }

  Map<String, dynamic> _decodePayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }

  Future<void> _registerToken(String? token) async {
    if (token == null || token.isEmpty) return;
    try {
      await _tokenDataSource.registerToken(token);
      _logger.info('Token FCM registrado no backend.');
    } on Object catch (e, st) {
      _logger.error('Falha ao registrar token FCM', error: e, stackTrace: st);
    }
  }

  Future<void> dispose() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
    await _onForeground.close();
  }
}
