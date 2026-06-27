import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final String employeeId;
  final String avatarUrl;
  final String phone;
  final String shiftStart;
  final String shiftEnd;
  final String workLocation;

  // GeoJSON object from Directus
  final Map<String, dynamic>? workCoordinates;

  // Allowed distance in meters
  final int geofenceRadius;

  final int totalLeaves;
  final int usedLeaves;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.employeeId,
    this.avatarUrl = '',
    this.phone = '',
    this.shiftStart = '09:00',
    this.shiftEnd = '17:30',
    this.workLocation = 'HQ - Tower A',
    this.workCoordinates,
    this.geofenceRadius = 100,
    this.totalLeaves = 21,
    this.usedLeaves = 5,
  });

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : '';
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((n) => n.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '';

    return parts.take(2).map((n) => n[0]).join().toUpperCase();
  }

  int get remainingLeaves => totalLeaves - usedLeaves;

  /// Latitude extracted from GeoJSON
  double? get workLatitude {
    if (workCoordinates == null) return null;

    final coordinates = workCoordinates!['coordinates'];

    if (coordinates == null || coordinates.length < 2) return null;

    return (coordinates[1] as num).toDouble();
  }

  /// Longitude extracted from GeoJSON
  double? get workLongitude {
    if (workCoordinates == null) return null;

    final coordinates = workCoordinates!['coordinates'];

    if (coordinates == null || coordinates.length < 2) return null;

    return (coordinates[0] as num).toDouble();
  }

  UserEntity copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    String? department,
    String? position,
    String? shiftStart,
    String? shiftEnd,
    String? workLocation,
    Map<String, dynamic>? workCoordinates,
    int? geofenceRadius,
  }) =>
      UserEntity(
        id: id,
        email: email,
        employeeId: employeeId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        department: department ?? this.department,
        position: position ?? this.position,
        shiftStart: shiftStart ?? this.shiftStart,
        shiftEnd: shiftEnd ?? this.shiftEnd,
        workLocation: workLocation ?? this.workLocation,
        workCoordinates: workCoordinates ?? this.workCoordinates,
        geofenceRadius: geofenceRadius ?? this.geofenceRadius,
        totalLeaves: totalLeaves,
        usedLeaves: usedLeaves,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        department,
        position,
        employeeId,
        workCoordinates,
        geofenceRadius,
        totalLeaves,
        usedLeaves,
      ];
}