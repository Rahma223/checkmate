import 'package:checkmate/features/attendance/domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.userId,
    required super.date,
    super.checkIn,
    super.checkOut,
    required super.status,
    required super.location,
    super.lat,
    super.lng,
    super.notes,
    super.breaks,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      userId: json['user']?.toString() ?? '',
      date: json['check_in'] != null
          ? DateTime.parse(json['check_in'])
          : DateTime.tryParse(json['date_created']?.toString() ?? '') ??
                DateTime.now(),
      checkIn: json['check_in'] != null
          ? DateTime.parse(json['check_in'])
          : null,
      checkOut: json['checkout'] != null
          ? DateTime.parse(json['checkout'])
          : null,
      status: json['status']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
      breaks:
          (json['breaks'] as List<dynamic>?)?.map((b) {
            final map = b as Map<String, dynamic>;
            return BreakEntity(
              id: map['id']?.toString() ?? '',
              type: map['type']?.toString() ?? '',
              startTime: map['start_time'] != null
                  ? DateTime.parse(map['start_time'])
                  : DateTime.now(),
              endTime: map['end_time'] != null
                  ? DateTime.parse(map['end_time'])
                  : null,
            );
          }).toList() ??
          const [],
    );
  }
}
