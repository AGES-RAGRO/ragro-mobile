import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/utils/polyline_decoder.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/delivery_tracking_cubit.dart';

/// Acompanhamento da entrega em tempo real (cliente): mapa com o produtor se
/// movendo (interpolação suave entre pings, sem "teleporte"), destino da SUA
/// entrega, ETA dinâmico e estados tipo iFood. Privacidade: nada das demais
/// paradas é exibido além da contagem à frente.
class DeliveryTrackingPage extends StatelessWidget {
  const DeliveryTrackingPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeliveryTrackingCubit>()..start(orderId),
      child: const _DeliveryTrackingView(),
    );
  }
}

class _DeliveryTrackingView extends StatefulWidget {
  const _DeliveryTrackingView();

  @override
  State<_DeliveryTrackingView> createState() => _DeliveryTrackingViewState();
}

class _DeliveryTrackingViewState extends State<_DeliveryTrackingView>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late final AnimationController _animation;

  LatLng? _displayedProducer;
  LatLng? _animFrom;
  LatLng? _animTo;

  /// Ícones do mapa (carro verde = produtor; casa = destino), gerados via Canvas
  /// para não depender de assets PNG. Carregados uma vez em didChangeDependencies.
  BitmapDescriptor? _producerIcon;
  BitmapDescriptor? _destinationIcon;
  bool _iconsRequested = false;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 900),
          )
          ..addListener(() {
            final from = _animFrom;
            final to = _animTo;
            if (from == null || to == null) return;
            final t = Curves.easeInOut.transform(_animation.value);
            setState(() {
              _displayedProducer = LatLng(
                from.latitude + (to.latitude - from.latitude) * t,
                from.longitude + (to.longitude - from.longitude) * t,
              );
            });
          });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iconsRequested) return;
    _iconsRequested = true;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    _loadMarkerIcons(dpr);
  }

  Future<void> _loadMarkerIcons(double dpr) async {
    // Carro verde (temática RAGRO) para o produtor; casa para a sua entrega.
    final producer = await _markerFromIcon(
      Icons.directions_car_filled,
      AppColors.lightGreen,
      dpr,
    );
    final destination = await _markerFromIcon(
      Icons.home_rounded,
      AppColors.darkGreen,
      dpr,
    );
    if (!mounted) return;
    setState(() {
      _producerIcon = producer;
      _destinationIcon = destination;
    });
  }

  /// Renderiza um [IconData] num círculo branco com borda colorida e devolve um
  /// [BitmapDescriptor] — marker nítido em qualquer densidade de tela, sem PNG.
  Future<BitmapDescriptor> _markerFromIcon(
    IconData icon,
    Color color,
    double dpr,
  ) async {
    final px = 46.0 * dpr;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(px / 2, px / 2);
    final radius = px / 2;

    canvas
      ..drawCircle(center, radius * 0.92, Paint()..color = Colors.white)
      ..drawCircle(
        center,
        radius * 0.92,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = px * 0.06,
      );

    final painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: px * 0.5,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      )
      ..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );

    final image = await recorder.endRecording().toImage(px.round(), px.round());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Move o marker suavemente da posição exibida para a nova (sem teleporte).
  void _animateProducerTo(LatLng target) {
    final current = _displayedProducer;
    if (current == null) {
      setState(() => _displayedProducer = target);
      return;
    }
    if (current.latitude == target.latitude &&
        current.longitude == target.longitude) {
      return;
    }
    _animFrom = current;
    _animTo = target;
    _animation.forward(from: 0);
  }

  String _etaLabel(int? etaSeconds) {
    if (etaSeconds == null) return '—';
    final minutes = (etaSeconds / 60).ceil();
    return minutes <= 1 ? '~1 min' : '~$minutes min';
  }

  (String, String) _phaseTexts(DeliveryTrackingState state) {
    return switch (state.phase) {
      DeliveryTrackingPhase.loading => ('Carregando...', ''),
      DeliveryTrackingPhase.waiting => (
        'Aguardando o produtor sair para entrega',
        'Você verá o mapa assim que a rota começar.',
      ),
      DeliveryTrackingPhase.awaitingLocation => (
        'Aguardando localização do produtor',
        'O produtor ainda não iniciou o compartilhamento da localização. Assim que ele estiver a caminho, você o verá no mapa.',
      ),
      DeliveryTrackingPhase.enRoute => (
        'Pedido em rota',
        '${state.stopsBefore} ${state.stopsBefore == 1 ? 'parada' : 'paradas'} antes da sua • chega em ${_etaLabel(state.etaSeconds)}',
      ),
      DeliveryTrackingPhase.nextStop => (
        'Sua entrega é a próxima!',
        'Chega em ${_etaLabel(state.etaSeconds)}',
      ),
      DeliveryTrackingPhase.arriving => (
        'O produtor está chegando!',
        'Menos de ${_etaLabel(state.etaSeconds)}',
      ),
      DeliveryTrackingPhase.delivered => (
        'Pedido entregue',
        'Obrigado por comprar direto do produtor!',
      ),
      DeliveryTrackingPhase.error => (
        'Não foi possível carregar o acompanhamento',
        'Verifique sua conexão e tente novamente.',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhar entrega'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
      ),
      body: BlocConsumer<DeliveryTrackingCubit, DeliveryTrackingState>(
        listener: (context, state) {
          final lat = state.producerLat;
          final lng = state.producerLng;
          if (lat != null && lng != null) {
            final target = LatLng(lat, lng);
            _animateProducerTo(target);
            _mapController?.animateCamera(CameraUpdate.newLatLng(target));
          }
        },
        builder: (context, state) {
          final (title, subtitle) = _phaseTexts(state);
          final destination =
              state.destinationLat != null && state.destinationLng != null
              ? LatLng(state.destinationLat!, state.destinationLng!)
              : null;
          final producer = _displayedProducer;
          final initialTarget =
              producer ?? destination ?? const LatLng(-30.0346, -51.2177);
          // Caminho calculado pelo Google (overviewPolyline) desenhado em verde.
          final routePoints = state.routePolyline == null
              ? const <LatLng>[]
              : decodePolyline(state.routePolyline!)
                    .map((p) => LatLng(p.$1, p.$2))
                    .toList();

          final showMap =
              state.phase != DeliveryTrackingPhase.loading &&
              state.phase != DeliveryTrackingPhase.waiting &&
              state.phase != DeliveryTrackingPhase.error;

          return Column(
            children: [
              Expanded(
                child: showMap
                    ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: initialTarget,
                          zoom: 14,
                        ),
                        onMapCreated: (controller) =>
                            _mapController = controller,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        polylines: {
                          if (routePoints.length >= 2)
                            Polyline(
                              polylineId: const PolylineId('route'),
                              points: routePoints,
                              color: AppColors.lightGreen,
                              width: 5,
                            ),
                        },
                        markers: {
                          if (producer != null)
                            Marker(
                              markerId: const MarkerId('producer'),
                              position: producer,
                              icon:
                                  _producerIcon ??
                                  BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueGreen,
                                  ),
                              anchor: const Offset(0.5, 0.5),
                              infoWindow: const InfoWindow(title: 'Produtor'),
                            ),
                          if (destination != null)
                            Marker(
                              markerId: const MarkerId('destination'),
                              position: destination,
                              icon:
                                  _destinationIcon ??
                                  BitmapDescriptor.defaultMarker,
                              anchor: const Offset(0.5, 0.5),
                              infoWindow: const InfoWindow(
                                title: 'Sua entrega',
                              ),
                            ),
                        },
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.phase == DeliveryTrackingPhase.error
                                    ? Icons.wifi_off_rounded
                                    : Icons.schedule_rounded,
                                size: 56,
                                color: AppColors.placeholder,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                state.phase == DeliveryTrackingPhase.delivered
                                ? AppColors.lightGreen
                                : state.live
                                ? AppColors.lightGreen
                                : AppColors.yellow,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: AppColors.placeholder,
                        ),
                      ),
                    ],
                    if (showMap && !state.live) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Atualizando a cada 10s',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: AppColors.placeholder,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
