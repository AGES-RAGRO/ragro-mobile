import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/services/tracking_socket.dart';
import 'package:ragro_mobile/features/orders/data/repositories/order_tracking_repository.dart';

/// Delivery phases shown to the customer (iFood-style experience).
enum DeliveryTrackingPhase {
  loading,
  waiting, // order not yet in an active route
  awaitingLocation, // in route, but producer hasn't sent a GPS position yet
  enRoute, // in route, with stops ahead of yours
  nextStop, // your delivery is the next stop
  arriving, // ETA < 5 min
  delivered,
  error,
}

class DeliveryTrackingState extends Equatable {
  const DeliveryTrackingState({
    this.phase = DeliveryTrackingPhase.loading,
    this.producerLat,
    this.producerLng,
    this.destinationLat,
    this.destinationLng,
    this.etaSeconds,
    this.stopsBefore = 0,
    this.live = false,
    this.updatedAt,
    this.routePolyline,
  });

  final DeliveryTrackingPhase phase;
  final double? producerLat;
  final double? producerLng;
  final double? destinationLat;
  final double? destinationLng;
  final int? etaSeconds;
  final int stopsBefore;

  /// true = receiving via WebSocket; false = polling fallback (10s).
  final bool live;
  final DateTime? updatedAt;

  /// Google-encoded route polyline (drawn on map). From the initial snapshot;
  /// does not change during delivery.
  final String? routePolyline;

  DeliveryTrackingState copyWith({
    DeliveryTrackingPhase? phase,
    double? producerLat,
    double? producerLng,
    double? destinationLat,
    double? destinationLng,
    int? etaSeconds,
    int? stopsBefore,
    bool? live,
    DateTime? updatedAt,
    String? routePolyline,
  }) {
    return DeliveryTrackingState(
      phase: phase ?? this.phase,
      producerLat: producerLat ?? this.producerLat,
      producerLng: producerLng ?? this.producerLng,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      stopsBefore: stopsBefore ?? this.stopsBefore,
      live: live ?? this.live,
      updatedAt: updatedAt ?? this.updatedAt,
      routePolyline: routePolyline ?? this.routePolyline,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    producerLat,
    producerLng,
    destinationLat,
    destinationLng,
    etaSeconds,
    stopsBefore,
    live,
    updatedAt,
    routePolyline,
  ];
}

/// Real-time delivery tracking for the customer: initial REST snapshot, live
/// STOMP stream (`/topic/routes/{routeId}`), graceful 10s-polling fallback when
/// the WebSocket goes silent.
@injectable
class DeliveryTrackingCubit extends Cubit<DeliveryTrackingState> {
  DeliveryTrackingCubit(this._repository, this._socket)
    : super(const DeliveryTrackingState());

  final OrderTrackingRepository _repository;
  final TrackingSocket _socket;

  String? _orderId;
  String? _routeId;
  Timer? _pollTimer;
  Timer? _liveWatchdog;

  Future<void> start(String orderId) async {
    _orderId = orderId;
    await _refreshSnapshot();
    if (isClosed) return;

    final routeId = _routeId;
    if (routeId != null) {
      await _socket.ensureConnected();
      if (isClosed) return;
      _socket.addOnConnect(_resubscribe);
      _resubscribe();
    }
    // Safety polling: if the WS has been silent for 15s, fetch the REST
    // snapshot every 10s.
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final last = state.updatedAt;
      final stale =
          last == null || DateTime.now().difference(last).inSeconds >= 15;
      if (stale) {
        unawaited(_refreshSnapshot());
      }
    });
  }

  void _resubscribe() {
    final routeId = _routeId;
    if (routeId == null || isClosed) return;
    _socket.subscribeRoute(routeId, _onBroadcast);
  }

  void _onBroadcast(Map<String, dynamic> message) {
    if (isClosed) return;
    final etas = (message['etas'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final mine = etas.where((e) => e['orderId'] == _orderId).toList();
    final myEta = mine.isNotEmpty ? mine.first : null;

    final stopStatus = myEta?['status'] as String?;
    final etaSeconds = (myEta?['etaSeconds'] as num?)?.toInt();
    final stopsBefore = (myEta?['stopsBefore'] as num? ?? 0).toInt();
    final lat = (message['latitude'] as num?)?.toDouble();
    final lng = (message['longitude'] as num?)?.toDouble();

    emit(
      state.copyWith(
        phase: _phaseFor(stopStatus, etaSeconds, stopsBefore, hasPosition: lat != null),
        producerLat: lat,
        producerLng: lng,
        etaSeconds: etaSeconds,
        stopsBefore: stopsBefore,
        live: true,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _refreshSnapshot() async {
    final orderId = _orderId;
    if (orderId == null) return;
    try {
      final tracking = await _repository.getTracking(orderId);
      if (isClosed) return;

      if (!tracking.available) {
        emit(
          state.copyWith(
            phase: tracking.stopStatus == 'DELIVERED'
                ? DeliveryTrackingPhase.delivered
                : DeliveryTrackingPhase.waiting,
            live: false,
            updatedAt: DateTime.now(),
          ),
        );
        return;
      }

      _routeId = tracking.routeId;
      emit(
        state.copyWith(
          phase: _phaseFor(
            tracking.stopStatus,
            tracking.etaSeconds,
            tracking.stopsBefore,
            hasPosition: tracking.producerLatitude != null,
          ),
          producerLat: tracking.producerLatitude,
          producerLng: tracking.producerLongitude,
          destinationLat: tracking.destinationLatitude,
          destinationLng: tracking.destinationLongitude,
          etaSeconds: tracking.etaSeconds,
          stopsBefore: tracking.stopsBefore,
          live: false,
          updatedAt: DateTime.now(),
          routePolyline: tracking.overviewPolyline,
        ),
      );
    } on Exception {
      if (isClosed) return;
      if (state.phase == DeliveryTrackingPhase.loading) {
        emit(state.copyWith(phase: DeliveryTrackingPhase.error));
      }
      // With data on screen, a polling failure is silent (retries in 10s).
    }
  }

  DeliveryTrackingPhase _phaseFor(
    String? stopStatus,
    int? etaSeconds,
    int stopsBefore, {
    required bool hasPosition,
  }) {
    if (stopStatus == 'DELIVERED') return DeliveryTrackingPhase.delivered;
    // In route but no producer ping yet: be explicit instead of an empty map.
    if (!hasPosition) return DeliveryTrackingPhase.awaitingLocation;
    if (etaSeconds != null && etaSeconds <= 300 && stopsBefore == 0) {
      return DeliveryTrackingPhase.arriving;
    }
    if (stopsBefore == 0) return DeliveryTrackingPhase.nextStop;
    return DeliveryTrackingPhase.enRoute;
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _liveWatchdog?.cancel();
    _socket.removeOnConnect(_resubscribe);
    final routeId = _routeId;
    if (routeId != null) {
      _socket.unsubscribeRoute(routeId);
    }
    return super.close();
  }
}
