import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// Conexão STOMP do rastreamento em tempo real (canal `/ws` do backend).
///
/// O handshake envia o JWT no header Authorization (o backend valida na security
/// chain e o interceptor STOMP autoriza tópico/envio por usuário). Reconexão
/// automática a cada 5s; quem usa registra callbacks de conexão para reassinar
/// tópicos e reenviar a última posição pendente.
@lazySingleton
class TrackingSocket {
  TrackingSocket(this._authLocal);

  final AuthLocalDataSource _authLocal;

  StompClient? _client;
  final _connectListeners = <void Function()>[];
  final _subscriptions = <String, StompUnsubscribe>{};

  bool get isConnected => _client?.connected ?? false;

  /// Garante uma conexão ativa (idempotente).
  Future<void> ensureConnected() async {
    if (_client?.connected == true) return;
    // Um cliente que existe mas não está conectado (pós-disconnect) ficava preso
    // — descarta-o antes de construir um novo para permitir o self-heal.
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
        // Ao desconectar, libera o cliente para que ensureConnected reconstrua a
        // conexão na próxima chamada em vez de devolver um cliente morto.
        onDisconnect: (_) => _client = null,
        // Erros de socket são tratados pela reconexão automática; o fallback de
        // polling do cliente cobre a janela sem conexão.
        onWebSocketError: (_) {},
      ),
    );
    _client = client;
    client.activate();
  }

  /// Callback disparado a cada (re)conexão — usado para reassinar e reenviar.
  void addOnConnect(void Function() listener) {
    _connectListeners.add(listener);
    if (isConnected) listener();
  }

  void removeOnConnect(void Function() listener) {
    _connectListeners.remove(listener);
  }

  /// Assina o tópico da rota; o callback recebe o JSON decodificado.
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

  /// Envia um ping de posição do produtor.
  void sendPosition(String routeId, Map<String, dynamic> payload) {
    if (!isConnected) return;
    _client?.send(
      destination: '/app/routes/$routeId/position',
      body: jsonEncode(payload),
    );
  }

  /// Encerra a conexão (logout/fim de uso). Idempotente.
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
