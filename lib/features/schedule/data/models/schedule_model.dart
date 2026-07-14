import 'package:checkmate/features/schedule/domain/entities/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    required super.userId,
    required super.day,
    required super.workDate,
    required super.shiftStart,
    required super.shiftEnd,
    required super.workLocation,
    required super.isWorkingDay,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id']?.toString() ?? '',
      userId: _userIdFromJson(json['user']),
      day: json['day']?.toString() ?? '',
      workDate: _dateFromJson(json['work_date']),
      shiftStart: _dateFromJson(json['shift_start']),
      shiftEnd: _dateFromJson(json['shift_end']),
      workLocation: json['work_location']?.toString() ?? '',
      isWorkingDay: json['is_working_day'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': userId,
    'day': day,
    'work_date': _dateOnly(workDate),
    'shift_start': shiftStart.toIso8601String(),
    'shift_end': shiftEnd.toIso8601String(),
    'work_location': workLocation,
    'is_working_day': isWorkingDay,
  };

  static String _userIdFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value['id']?.toString() ?? '';
    }
    if (value is Map) {
      return value['id']?.toString() ?? '';
    }

    return value?.toString() ?? '';
  }

  static DateTime _dateFromJson(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.parse(raw);
  }

  static String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
