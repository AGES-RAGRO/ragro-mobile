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

  Set<Marker> _buildMarkers() {
    return _producers.map((producer) {
      return Marker(
        markerId: MarkerId(producer.id),
        position: LatLng(producer.latitude, producer.longitude),
        infoWindow: InfoWindow(
          title: producer.farmName,
          snippet: 'Clique para ver o produtor',
          onTap: () {
            context.push('/customer/home/producer/${producer.id}');
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
