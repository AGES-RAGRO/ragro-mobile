import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/services/tracking_socket.dart';

/// Publica a posição do produtor durante a rota ativa.
///
/// Frequência adaptativa (decisão de produto): envia a cada ~5s quando em
/// movimento (≥15m desde o último envio) e a cada ~30s parado — equilíbrio
/// precisão × bateria × ingestão. No Android, o stream roda num foreground
/// service (notificação persistente) para continuar emitindo com o app atrás
/// do Google Maps de navegação; no iOS, background updates de localização.
/// Offline: guarda a última posição e a reenvia na reconexão do socket.
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

  /// Começa a publicar para a rota. Idempotente por rota.
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

  /// Para de publicar (fim/cancelamento da rota ou tela fechada).
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
      // Offline: guarda só a ÚLTIMA posição; o histórico intermediário não tem
      // valor para o cliente e o backend descartaria saltos atrasados.
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
