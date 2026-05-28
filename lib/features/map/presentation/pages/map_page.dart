import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/map/data/map_repository.dart';
import 'package:ragro_mobile/features/map/domain/producer_location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  List<ProducerLocation> _producers = [];
  final Map<String, BitmapDescriptor> _customMarkers = {};
  bool _isLoading = true;
  Position? _currentPosition;
  final LatLng _defaultLocation = const LatLng(
    -30.0346,
    -51.2177,
  ); // Porto Alegre

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    await _getCurrentLocation();
    await _loadProducers();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 12,
            ),
          ),
        );
      }
    } on Exception catch (_) {
      // Ignore location error
    }
  }

  Future<void> _loadProducers() async {
    try {
      final repository = getIt<MapRepository>();
      final producers = await repository.getProducerLocations();

      setState(() {
        _producers = producers;
        _isLoading = false;
      });

      // Carregar os marcadores customizados em background para não travar a tela
      for (final producer in producers) {
        _createCustomMarker(producer.avatarUrl).then((marker) {
          if (mounted) {
            setState(() {
              _customMarkers[producer.id] = marker;
            });
          }
        });
      }
    } on Exception catch (_) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao carregar mapa')));
      }
    }
  }

  Future<BitmapDescriptor> _createCustomMarker(String? avatarUrl) async {
    const int size = 180;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Fundo do pino (Gota verde escuro)
    final Paint paint = Paint()..color = AppColors.darkGreen;
    final Path path = Path()
      ..moveTo(size / 2, size.toDouble())
      ..quadraticBezierTo(size * 0.1, size * 0.6, size * 0.1, size * 0.4)
      ..arcToPoint(
        Offset(size * 0.9, size * 0.4),
        radius: const Radius.circular(size * 0.4),
        clockwise: true,
      )
      ..quadraticBezierTo(size * 0.9, size * 0.6, size / 2, size.toDouble());

    canvas.drawPath(path, paint);

    // Círculo branco interno
    final Paint whitePaint = Paint()..color = Colors.white;
    final Offset circleCenter = Offset(size / 2, size * 0.4);
    final double circleRadius = size * 0.32;
    canvas.drawCircle(circleCenter, circleRadius, whitePaint);

    ui.Image? profileImage;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      try {
        // Corrige o localhost para o emulador Android
        String resolvedUrl = avatarUrl;
        if (Theme.of(context).platform == TargetPlatform.android &&
            resolvedUrl.contains('localhost')) {
          resolvedUrl = resolvedUrl.replaceAll('localhost', '10.0.2.2');
        }

        final response = await Dio().get<List<int>>(
          resolvedUrl,
          options: Options(
            responseType: ResponseType.bytes,
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        if (response.data != null) {
          final Uint8List bytes = Uint8List.fromList(response.data!);
          final ui.Codec codec = await ui.instantiateImageCodec(
            bytes,
            targetWidth: (circleRadius * 2).toInt(),
            targetHeight: (circleRadius * 2).toInt(),
          );
          final ui.FrameInfo fi = await codec.getNextFrame();
          profileImage = fi.image;
        }
      } catch (_) {
        // Fallback for failed image download
      }
    }

    if (profileImage != null) {
      // Desenha a foto de perfil recortada
      canvas.save();
      canvas.clipPath(
        Path()..addOval(
          Rect.fromCircle(center: circleCenter, radius: circleRadius - 2),
        ),
      );
      canvas.drawImage(
        profileImage,
        Offset(
          circleCenter.dx - profileImage.width / 2,
          circleCenter.dy - profileImage.height / 2,
        ),
        Paint(),
      );
      canvas.restore();
    } else {
      // Ícone genérico
      final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );
      textPainter.text = TextSpan(
        text: String.fromCharCode(Icons.storefront.codePoint),
        style: TextStyle(
          fontSize: size * 0.4,
          fontFamily: Icons.storefront.fontFamily,
          color: AppColors.darkGreen,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          circleCenter.dx - textPainter.width / 2,
          circleCenter.dy - textPainter.height / 2,
        ),
      );
    }

    // Borda fina
    final Paint borderPaint = Paint()
      ..color = AppColors.darkGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(circleCenter, circleRadius, borderPaint);

    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      size,
      size,
    );
    final ByteData? byteData = await markerAsImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  Set<Marker> _buildMarkers() {
    return _producers.map((producer) {
      return Marker(
        markerId: MarkerId(producer.id),
        position: LatLng(producer.latitude, producer.longitude),
        infoWindow: InfoWindow(
          title: producer.farmName,
          snippet: 'Clique para ver o produtor',
          onTap: () {
            context.push('/customer/producer/${producer.id}');
          },
        ),
        icon:
            _customMarkers[producer.id] ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapa de Produtores',
          style: TextStyle(color: AppColors.darkGreen),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkGreen),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      )
                    : _defaultLocation,
                zoom: _currentPosition != null ? 12.0 : 10.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _buildMarkers(),
              myLocationEnabled: true,
            ),
    );
  }
}
