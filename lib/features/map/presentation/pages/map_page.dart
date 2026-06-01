import 'dart:math' as math;
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
      // Don't just center on the current position: the actual framing
      // (fitBounds) happens in _fitCamera(), keeping the producer pins
      // visible even if the user/emulator is far away.
      await _fitCamera();
    } on Exception catch (_) {
      // Ignore location error
    }
  }

  /// Frames the camera to show all producers (and the current position, if
  /// available); otherwise pins may fall off-screen.
  Future<void> _fitCamera() async {
    final controller = _mapController;
    if (controller == null) return;

    final points = _producers
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();
    if (_currentPosition != null) {
      points.add(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      );
    }
    if (points.isEmpty) return;

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 13),
      );
      return;
    }

    final bounds = _boundsFromPoints(points);
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 64),
      );
    } on Exception {
      // The map may not be sized yet on the first call; retry after the
      // first frame.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      try {
        await controller.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 64),
        );
      } on Exception {
        // Ignore: keep the initial framing.
      }
    }
  }

  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _loadProducers() async {
    try {
      final repository = getIt<MapRepository>();
      final producers = await repository.getProducerLocations();

      setState(() {
        _producers = producers;
        _isLoading = false;
      });

      // Load custom markers in the background so the screen doesn't freeze.
      for (final producer in producers) {
        final imageUrl =
            (producer.coverUrl != null && producer.coverUrl!.isNotEmpty)
            ? producer.coverUrl
            : producer.avatarUrl;
        _createCustomMarker(imageUrl).then((marker) {
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

    // Pin background (dark green teardrop)
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

    // Inner white circle
    final Paint whitePaint = Paint()..color = Colors.white;
    final Offset circleCenter = Offset(size / 2, size * 0.4);
    final double circleRadius = size * 0.32;
    canvas.drawCircle(circleCenter, circleRadius, whitePaint);

    ui.Image? profileImage;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      try {
        // Rewrite localhost for the Android emulator.
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
      // Draw the clipped profile photo.
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
      // Generic icon
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

    // Thin border
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
          : Stack(
              children: [
                GoogleMap(
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
                    _fitCamera();
                  },
                  markers: _buildMarkers(),
                  myLocationEnabled: true,
                ),
                if (_producers.isEmpty) _buildEmptyState(),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.location_off_outlined, color: AppColors.darkGreen),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Nenhum produtor com localização disponível no momento.',
                  style: TextStyle(fontSize: 13, color: AppColors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
