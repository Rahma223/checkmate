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
      workDate: _parseDate(json['work_date']),
      shiftStart: _parseDateTimeOrTime(json['shift_start']),
      shiftEnd: _parseDateTimeOrTime(json['shift_end']),
      workLocation: json['location']?.toString() ?? '',
      isWorkingDay: json['is_working_day'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'day': day,
      'work_date': _formatDate(workDate),
      'shift_start': _formatTime(shiftStart),
      'shift_end': _formatTime(shiftEnd),
      'location': workLocation,
      'is_working_day': isWorkingDay,
    };
  }

  static String _userIdFromJson(dynamic value) {
    if (value == null) return '';

    // Many-to-Many
    if (value is List && value.isNotEmpty) {
      final first = value.first;

      if (first is Map<String, dynamic>) {
        return first['directus_users_id']?.toString() ?? '';
      }

      if (first is Map) {
        return first['directus_users_id']?.toString() ?? '';
      }
    }

    // Many-to-One
    if (value is Map<String, dynamic>) {
      return value['id']?.toString() ?? '';
    }

    if (value is Map) {
      return value['id']?.toString() ?? '';
    }

    return value.toString();
  }

  static DateTime _parseDate(dynamic value) {
    final raw = value?.toString();

    if (raw == null || raw.isEmpty) {
      return DateTime.now();
    }

    return DateTime.parse(raw);
  }

  static DateTime _parseDateTimeOrTime(dynamic value) {
    final raw = value?.toString();

    if (raw == null || raw.isEmpty) {
      return DateTime.now();
    }

    // Time only: 09:00:00
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(raw)) {
      return DateTime.parse('1970-01-01T$raw');
    }

    return DateTime.parse(raw);
  }

  static String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  static String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:"
        "${time.second.toString().padLeft(2, '0')}";
  }
}