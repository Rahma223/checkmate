import 'dart:async';

import 'package:checkmate/core/services/geofence_service.dart';
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
  StreamSubscription<Position>? _positionSubscription;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  LatLng _userLocation = const LatLng(40.7484, -73.9967);
  double? _distanceInMeters;
  bool? _isInsideGeofence;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationError = 'Location services are disabled.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _locationError = 'Location permission was denied.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _handlePosition(position);

      _focusMap();
      _updateMarkers();
      _startLocationUpdates();
    } catch (e) {
      setState(() {
        _locationError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_handlePosition);
  }

  void _handlePosition(Position position) {
    if (!mounted) {
      return;
    }

    final user = context.read<AuthCubit>().currentUser;
    GeofenceResult? geofenceResult;

    if (user != null) {
      try {
        geofenceResult = context
            .read<GeofenceService>()
            .checkGeofenceFromPosition(user, position);
      } catch (e) {
        _locationError = e.toString().replaceFirst('Exception: ', '');
      }
    }

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _distanceInMeters = geofenceResult?.distanceInMeters;
      _isInsideGeofence = geofenceResult?.isInside;
      if (geofenceResult != null) {
        _locationError = null;
      }
    });
  }

  String _formatDistance(double? distanceInMeters) {
    if (distanceInMeters == null) {
      return '--';
    }

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    }

    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
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
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Distance',
              value: _formatDistance(_distanceInMeters),
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
        if (_positionSubscription == null) {
          _requestLocationPermission();
        }
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
                          _WorkAreaStatus(
                            companyLocationAvailable: companyLocation != null,
                            inside: _isInsideGeofence,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MetricChip(
                            label: 'Distance',
                            value: _formatDistance(_distanceInMeters),
                            icon: Icons.social_distance_rounded,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _locationError ?? 'Updates with your location',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: _locationError == null
                                        ? AppColors.onSurfaceVariant
                                        : AppColors.error,
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
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}

class _WorkAreaStatus extends StatelessWidget {
  final bool companyLocationAvailable;
  final bool? inside;

  const _WorkAreaStatus({
    required this.companyLocationAvailable,
    required this.inside,
  });

  @override
  Widget build(BuildContext context) {
    final isInside = inside == true;
    final isKnown = companyLocationAvailable && inside != null;
    final color = isKnown
        ? (isInside ? AppColors.success : AppColors.error)
        : AppColors.outline;
    final background = isKnown
        ? (isInside ? AppColors.successContainer : AppColors.errorContainer)
        : AppColors.surfaceContainerLow;
    final label = !companyLocationAvailable
        ? 'Missing work area'
        : inside == null
        ? 'Locating...'
        : isInside
        ? 'Inside work area'
        : 'Outside work area';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    ),
  );
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
