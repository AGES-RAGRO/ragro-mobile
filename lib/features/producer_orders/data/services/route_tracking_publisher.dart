import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/services/tracking_socket.dart';

/// Publishes the producer's position during an active route.
///
/// Adaptive rate: every ~5s when moving (≥15m since last send), every ~30s when
/// stationary — accuracy vs battery vs ingestion. Android uses a foreground
/// service to keep emitting behind Google Maps navigation; iOS uses background
/// location updates. Offline: keeps the last position and resends on reconnect.
@lazySingleton
class RouteTrackingPublisher {
  RouteTrackingPublisher(this._socket);

  final TrackingSocket _socket;

  static const _movingInterval = Duration(seconds: 5);
  static const _stationaryInterval = Duration(seconds: 30);
  static const _movingDistanceMeters = 15.0;

  StreamSubscription<Position>? _subscription;
  String? _routeId;
  DateTime? _lastSentAt;
  Position? _lastSentPosition;
  Map<String, dynamic>? _pendingPayload;
  void Function()? _onReconnect;

  bool get isActive => _routeId != null;

  /// Starts publishing for the route. Idempotent per route.
  Future<void> start(String routeId) async {
    if (_routeId == routeId) return;
    await stop();
    _routeId = routeId;

    await _socket.ensureConnected();
    _onReconnect = _flushPending;
    _socket.addOnConnect(_onReconnect!);

    late final LocationSettings settings;
    if (!kIsWeb && Platform.isAndroid) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Entrega em andamento',
          notificationText:
              'Sua localização está sendo compartilhada com os clientes da rota.',
          enableWakeLock: true,
        ),
      );
    } else if (!kIsWeb && Platform.isIOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        showBackgroundLocationIndicator: true,
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }

    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_onPosition, onError: (_) {});
  }

  /// Stops publishing (route ended/cancelled or screen closed).
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_onReconnect != null) {
      _socket.removeOnConnect(_onReconnect!);
      _onReconnect = null;
    }
    _routeId = null;
    _lastSentAt = null;
    _lastSentPosition = null;
    _pendingPayload = null;
  }

  void _onPosition(Position position) {
    final routeId = _routeId;
    if (routeId == null) return;

    final now = DateTime.now();
    final elapsed = _lastSentAt == null
        ? _stationaryInterval
        : now.difference(_lastSentAt!);
    final moved = _lastSentPosition == null
        ? double.infinity
        : Geolocator.distanceBetween(
            _lastSentPosition!.latitude,
            _lastSentPosition!.longitude,
            position.latitude,
            position.longitude,
          );

    final shouldSend = elapsed >= _stationaryInterval ||
        (elapsed >= _movingInterval && moved >= _movingDistanceMeters);
    if (!shouldSend) return;

    final payload = <String, dynamic>{
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracyMeters': position.accuracy,
      'speedKmh': position.speed * 3.6,
    };

    if (_socket.isConnected) {
      _socket.sendPosition(routeId, payload);
      _pendingPayload = null;
    } else {
      // Offline: keep only the LAST position; intermediate history is useless to
      // the customer and the backend would drop stale jumps.
      _pendingPayload = payload;
    }
    _lastSentAt = now;
    _lastSentPosition = position;
  }

  void _flushPending() {
    final routeId = _routeId;
    final pending = _pendingPayload;
    if (routeId != null && pending != null) {
      _socket.sendPosition(routeId, pending);
      _pendingPayload = null;
    }
  }
}
