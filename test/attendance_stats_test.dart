import 'package:checkmate/features/attendance/domain/entities/attendance_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attendance percentage is based on present days and working days', () {
    const stats = MonthlyStatsEntity(
      present: 18,
      absent: 1,
      late: 2,
      onLeave: 2,
      totalHours: 153.5,
      avgHours: 8.5,
      workingDays: 23,
      overtimeHours: 6.5,
    );

    expect(stats.attendancePct, closeTo(78.2608, 0.001));
  });

  test('worked hours subtract break duration', () {
    final checkIn = DateTime(2026, 7, 13, 9);
    final checkOut = DateTime(2026, 7, 13, 17, 30);
    final record = AttendanceEntity(
      id: 'att_1',
      userId: 'user_1',
      date: checkIn,
      checkIn: checkIn,
      checkOut: checkOut,
      status: 'checked_out',
      location: 'HQ',
      breaks: [
        BreakEntity(
          id: 'break_1',
          startTime: DateTime(2026, 7, 13, 12),
          endTime: DateTime(2026, 7, 13, 12, 30),
          type: 'lunch',
        ),
      ],
    );

    expect(record.workedHours, 8);
  });
}
