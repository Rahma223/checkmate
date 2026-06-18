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
      breaks: (() {
        final raw = json['breaks'] ?? json['attendance_breaks'];
        if (raw is! List) return <BreakEntity>[];
        return raw.map<BreakEntity>((e) {
          if (e is Map) {
            final map = e as Map<String, dynamic>;
            final start =
                DateTime.tryParse(map['start_time']?.toString() ?? '') ??
                DateTime.tryParse(json['check_in']?.toString() ?? '') ??
                DateTime.now();
            final end = map['end_time'] != null
                ? DateTime.tryParse(map['end_time']?.toString() ?? '')
                : null;
            return BreakEntity(
              id: map['id']?.toString() ?? '',
              startTime: start,
              endTime: end,
              type: map['type']?.toString() ?? '',
            );
          }

          // If break item is an id (int/string) or unexpected type, create a placeholder
          final id = e?.toString() ?? DateTime.now().toIso8601String();
          final fallbackStart =
              DateTime.tryParse(json['check_in']?.toString() ?? '') ??
              DateTime.now();
          return BreakEntity(
            id: id,
            startTime: fallbackStart,
            endTime: null,
            type: '',
          );
        }).toList();
      }()),
    );
  }
}
