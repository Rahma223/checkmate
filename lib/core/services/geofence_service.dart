import 'package:checkmate/features/auth/domain/entities/user_entity.dart';
import 'package:geolocator/geolocator.dart';

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
    final workLatitude = user.workLatitude;
    final workLongitude = user.workLongitude;

    if (workLatitude == null || workLongitude == null) {
      throw Exception('Work coordinates are missing.');
    }

    final currentPosition = await getCurrentLocation();

    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      workLatitude,
      workLongitude,
    );
  }

  /// Returns whether the current device location is inside the user's allowed
  /// work area.
  ///
  /// The allowed area is defined by [UserEntity.geofenceRadius] in meters.
  Future<bool> isInsideGeofence(UserEntity user) async {
    final distance = await calculateDistance(user);

    return distance <= user.geofenceRadius;
  }
}
