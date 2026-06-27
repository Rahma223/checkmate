import 'package:equatable/equatable.dart';

class BreakEntity extends Equatable {
  final String id;

  final DateTime startTime;

  final DateTime? endTime;

  final String type;

  const BreakEntity({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.type,
  });

  bool get isActive => endTime == null;

  Duration? get duration =>
      endTime != null ? endTime!.difference(startTime) : null;

  @override
  List<Object?> get props => [id, startTime, endTime, type];
}

class AttendanceEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status;
  final String location;
  final double? lat;
  final double? lng;
  final String? notes;
  final List<BreakEntity> breaks;

  const AttendanceEntity({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    required this.location,
    this.lat,
    this.lng,
    this.notes,
    this.breaks = const [],
  });

  Duration get totalDuration {
    if (checkIn == null) return Duration.zero;
    final endTime = checkOut ?? DateTime.now();
    return endTime.difference(checkIn!);
  }

  Duration get breakDuration {
    final dayEnd = checkOut ?? DateTime.now();
    final dayStart = checkIn ?? DateTime.fromMillisecondsSinceEpoch(0);
    return breaks.fold<Duration>(Duration.zero, (sum, b) {
      var start = b.startTime;
      var end = b.endTime ?? dayEnd;

      // clamp break interval to the attendance window [dayStart, dayEnd]
      if (start.isBefore(dayStart)) start = dayStart;
      if (end.isAfter(dayEnd)) end = dayEnd;

      final diff = end.difference(start);
      if (diff.isNegative) return sum;
      return sum + diff;
    });
  }

  Duration get workedDuration {
    if (checkIn == null) return Duration.zero;
    final worked = totalDuration - breakDuration;
    return worked.isNegative ? Duration.zero : worked;
  }

  double get workedHours => workedDuration.inMinutes / 60.0;

  double attendancePct([double expectedHours = 8.5]) {
    if (expectedHours <= 0) return 0;
    return (workedHours / expectedHours * 100).clamp(0, 100);
  }

  AttendanceEntity copyWith({
    DateTime? checkIn,
    DateTime? checkOut,
    String? status,
    List<BreakEntity>? breaks,
  }) => AttendanceEntity(
    id: id,
    userId: userId,
    date: date,
    location: location,
    lat: lat,
    lng: lng,
    notes: notes,
    checkIn: checkIn ?? this.checkIn,
    checkOut: checkOut ?? this.checkOut,
    status: status ?? this.status,
    breaks: breaks ?? this.breaks,
  );

  @override
  List<Object?> get props => [id, userId, date, status, checkIn, checkOut];
}

class MonthlyStatsEntity extends Equatable {
  final int present;
  final int absent;
  final int late;
  final int onLeave;
  final double totalHours;
  final double avgHours;
  final int workingDays;
  final double overtimeHours;

  const MonthlyStatsEntity({
    required this.present,
    required this.absent,
    required this.late,
    required this.onLeave,
    required this.totalHours,
    required this.avgHours,
    required this.workingDays,
    required this.overtimeHours,
  });

  double get attendancePct =>
      workingDays > 0 ? (present / workingDays) * 100 : 0;

  @override
  List<Object?> get props => [
    present,
    absent,
    late,
    onLeave,
    totalHours,
    workingDays,
  ];
}
