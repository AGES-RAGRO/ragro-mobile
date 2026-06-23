import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// STOMP connection for real-time tracking (backend `/ws` channel).
///
/// Handshake sends the JWT in the Authorization header; backend authorizes
/// topic/send per user. Auto-reconnects every 5s; callers register connect
/// callbacks to re-subscribe topics and resend the last pending position.
@lazySingleton
class TrackingSocket {
  TrackingSocket(this._authLocal);

  final AuthLocalDataSource _authLocal;

  StompClient? _client;
  final _connectListeners = <void Function()>[];
  final _subscriptions = <String, StompUnsubscribe>{};

  bool get isConnected => _client?.connected ?? false;

  /// Ensures an active connection (idempotent).
  Future<void> ensureConnected() async {
    if (_client?.connected == true) return;
    // Discard a stale (post-disconnect) client before rebuilding to self-heal.
    if (_client != null) {
      _client?.deactivate();
      _client = null;
    }
    final token = await _authLocal.getToken();
    if (token == null || token.isEmpty) return;

    final headers = {'Authorization': 'Bearer $token'};
    final client = StompClient(
      config: StompConfig(
        url: ApiEndpoints.wsUrl,
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        onConnect: (_) {
          for (final listener in List.of(_connectListeners)) {
            listener();
          }
        },
        // Release the client on disconnect so ensureConnected rebuilds it.
        onDisconnect: (_) => _client = null,
        // Socket errors handled by auto-reconnect; client polling covers the gap.
        onWebSocketError: (_) {},
      ),
    );
    _client = client;
    client.activate();
  }

  /// Callback fired on each (re)connect — used to re-subscribe and resend.
  void addOnConnect(void Function() listener) {
    _connectListeners.add(listener);
    if (isConnected) listener();
  }

  void removeOnConnect(void Function() listener) {
    _connectListeners.remove(listener);
  }

  /// Subscribes to the route topic; callback receives the decoded JSON.
  void subscribeRoute(String routeId, void Function(Map<String, dynamic>) onMessage) {
    final destination = '/topic/routes/$routeId';
    _subscriptions.remove(destination)?.call();
    final unsubscribe = _client?.subscribe(
      destination: destination,
      callback: (frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) onMessage(decoded);
      },
    );
    if (unsubscribe != null) _subscriptions[destination] = unsubscribe;
  }

  void unsubscribeRoute(String routeId) {
    _subscriptions.remove('/topic/routes/$routeId')?.call();
  }

  /// Sends a producer position ping.
  void sendPosition(String routeId, Map<String, dynamic> payload) {
    if (!isConnected) return;
    _client?.send(
      destination: '/app/routes/$routeId/position',
      body: jsonEncode(payload),
    );
  }

  /// Closes the connection (logout/teardown). Idempotent.
  void shutdown() {
    for (final unsubscribe in _subscriptions.values) {
      unsubscribe();
    }
    _subscriptions.clear();
    _connectListeners.clear();
    _client?.deactivate();
    _client = null;
  }
}
