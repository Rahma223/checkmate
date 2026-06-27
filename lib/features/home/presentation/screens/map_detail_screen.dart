import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:checkmate/core/theme/app_theme.dart';
import 'package:checkmate/presentation/cubits/cubits.dart';

class MapDetailScreen extends StatefulWidget {
  const MapDetailScreen({super.key});

  @override
  State<MapDetailScreen> createState() => _MapDetailScreenState();
}

class _MapDetailScreenState extends State<MapDetailScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  LatLng _userLocation = const LatLng(40.7484, -73.9967);

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      _focusMap();
      _updateMarkers();
    } catch (_) {}
  }

  LatLng? _companyLocation() {
    final user = context.read<AuthCubit>().currentUser;
    final latitude = user?.workLatitude;
    final longitude = user?.workLongitude;

    if (latitude == null || longitude == null) {
      return null;
    }

    return LatLng(latitude, longitude);
  }

  void _updateMarkers() {
    final user = context.read<AuthCubit>().currentUser;
    final companyLocation = _companyLocation();

    _markers.clear();
    _circles.clear();

    if (companyLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('company'),
          position: companyLocation,
          infoWindow: InfoWindow(
            title: user?.workLocation ?? 'Company Location',
            snippet: 'Allowed check-in area',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      _circles.add(
        Circle(
          circleId: const CircleId('company_geofence'),
          center: companyLocation,
          radius: (user?.geofenceRadius ?? 100).toDouble(),
          fillColor: AppColors.primary.withOpacity(0.12),
          strokeColor: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _focusMap() {
    final controller = _mapController;
    if (controller == null) {
      return;
    }

    final companyLocation = _companyLocation();

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: companyLocation ?? _userLocation,
          zoom: companyLocation != null ? 17 : 15,
        ),
      ),
    );
  }

  String _formatCoordinates(LatLng? location) {
    if (location == null) {
      return 'N/A';
    }

    return '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
  }

  void _showLocationDetails(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    final companyLocation = _companyLocation();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: 'Location Name',
              value: user?.workLocation ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Coordinates',
              value: _formatCoordinates(companyLocation),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Allowed Radius',
              value: '${user?.geofenceRadius ?? 100} meters',
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Your Location',
              value: _formatCoordinates(_userLocation),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (ctx, state) {
        _updateMarkers();
        _focusMap();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Workspace Map'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.person_outline_rounded),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: _companyLocation() ?? _userLocation,
                  zoom: _companyLocation() != null ? 17.0 : 15.0,
                ),
                markers: _markers,
                circles: _circles,
                onMapCreated: (controller) {
                  _mapController = controller;
                  _updateMarkers();
                  _focusMap();
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapToolbarEnabled: true,
                compassEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
              ),
            ),
            BlocBuilder<HomeCubit, HomeState>(
              builder: (ctx, state) {
                final user = context.read<AuthCubit>().currentUser;
                final companyLocation = _companyLocation();

                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Company Location',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.workLocation ?? 'N/A',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${user?.geofenceRadius ?? 100}m allowed radius',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: companyLocation != null
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.errorContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              companyLocation != null ? 'Geofence' : 'Missing',
                              style: TextStyle(
                                fontSize: 12,
                                color: companyLocation != null
                                    ? AppColors.primary
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: companyLocation != null
                                  ? _focusMap
                                  : null,
                              icon: const Icon(Icons.navigation_outlined),
                              label: const Text('Focus Company'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () => _showLocationDetails(context),
                            child: const Text('Details'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
