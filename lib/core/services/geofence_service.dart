import 'package:checkmate/features/auth/domain/entities/user_entity.dart';
import 'package:geolocator/geolocator.dart';

class GeofenceResult {
  final double distanceInMeters;
  final bool isInside;

  const GeofenceResult({
    required this.distanceInMeters,
    required this.isInside,
  });
}

/// Provides location and geofence checks for attendance workflows.
///
/// The service is UI-agnostic and can be reused by any feature that needs to
/// validate the device position against a user's assigned work coordinates.
class GeofenceService {
  /// Returns the device's current GPS position using high accuracy.
  ///
  /// Throws an [Exception] with a user-readable message when location services
  /// are disabled or when the required location permission is denied.
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Please enable it from settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Calculates the distance in meters between the current device location and
  /// the user's configured work coordinates.
  ///
  /// Directus stores GeoJSON points as `[longitude, latitude]`; [UserEntity]
  /// exposes helper getters that return the values in the expected order.
  /// Throws an [Exception] when the user's work coordinates are missing.
  Future<double> calculateDistance(UserEntity user) async {
    final currentPosition = await getCurrentLocation();

    return calculateDistanceFromPosition(user, currentPosition);
  }

  /// Calculates the distance in meters from a known position to the user's
  /// configured work coordinates.
  double calculateDistanceFromPosition(UserEntity user, Position position) {
    final workLatitude = user.workLatitude;
    final workLongitude = user.workLongitude;

    if (workLatitude == null || workLongitude == null) {
      throw Exception('Work coordinates are missing.');
    }

    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      workLatitude,
      workLongitude,
    );
  }

  /// Returns whether the current device location is inside the user's allowed
  /// work area.
  ///
  /// The allowed area is defined by [UserEntity.geofenceRadius] in meters.
  Future<bool> isInsideGeofence(UserEntity user) async {
    final result = await checkGeofence(user);

    return result.isInside;
  }

  /// Returns both distance and inside/outside state using a single distance
  /// calculation.
  Future<GeofenceResult> checkGeofence(UserEntity user) async {
    final currentPosition = await getCurrentLocation();

    return checkGeofenceFromPosition(user, currentPosition);
  }

  /// Returns both distance and inside/outside state for a known position.
  GeofenceResult checkGeofenceFromPosition(UserEntity user, Position position) {
    final distance = calculateDistanceFromPosition(user, position);

    return GeofenceResult(
      distanceInMeters: distance,
      isInside: distance <= user.geofenceRadius,
    );
  }
}
