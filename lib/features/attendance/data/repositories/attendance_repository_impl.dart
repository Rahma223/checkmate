import 'package:dartz/dartz.dart';
import 'package:checkmate/core/errors/failures.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';
import 'package:checkmate/features/attendance/data/models/attendance_model.dart';
import 'package:checkmate/features/attendance/data/services/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceEntity? _currentAttendance;

  AttendanceRepositoryImpl(this.remoteDataSource);

  // =========================
  // CACHE
  // =========================
  void clearCache() => _currentAttendance = null;

  AttendanceEntity _map(Map<String, dynamic> json) {
    return AttendanceModel.fromJson(json);
  }

  // =========================
  // GET TODAY (PRIVATE)
  // =========================
  Future<Either<Failure, AttendanceEntity?>> _getToday(String userId) async {
    try {
      final data = await remoteDataSource.getTodayRecord(userId: userId);

      if (data == null) return const Right(null);

      final attendance = _map(data);
      _currentAttendance = attendance;

      return Right(attendance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // =========================
  // WRAPPER FOR TODAY RECORD
  // =========================
  Future<Either<Failure, T>> _withToday<T>(
    String userId,
    Future<Either<Failure, T>> Function(AttendanceEntity record) action,
  ) async {
    final result = await _getToday(userId);

    return result.fold(
      (f) => Left(f),
      (record) async {
        if (record == null) {
          return Left(ServerFailure('No active attendance found'));
        }
        return await action(record);
      },
    );
  }

  // =========================
  // CHECK IN
  // =========================
  @override
  Future<Either<Failure, AttendanceEntity>> checkIn({
    required String userId,
    required double lat,
    required double lng,
    required String location,
  }) async {
    try {
      final data = await remoteDataSource.checkIn(
        userId: userId,
        lat: lat,
        lng: lng,
        location: location,
      );

      final attendance = AttendanceModel.fromJson(data);
      _currentAttendance = attendance;

      return Right(attendance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity?>> getTodayRecord({
    required String userId,
  }) async {
    try {
      print('AttendanceRepositoryImpl.getTodayRecord user=$userId');
      final data = await remoteDataSource.getTodayRecord(userId: userId);
      if (data == null) {
        print('AttendanceRepositoryImpl.getTodayRecord: no record found');
        return const Right(null);
      }

      final attendance = AttendanceModel.fromJson(data);
      print(
        'AttendanceRepositoryImpl.getTodayRecord: loaded record=${attendance.id} breaks=${attendance.breaks.length}',
      );
      _currentAttendance = attendance;
      return Right(attendance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getHistory({
    required String userId,
    String? status,
  }) async {
    try {
      final data = await remoteDataSource.getHistory(
        userId: userId,
        status: status,
      );

      final history = data
          .map<AttendanceEntity>(
            (e) => AttendanceModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      for (final item in history) {
        print("Attendance: ${item.id}");
        print("Break Count: ${item.breaks.length}");
      }

      return Right(history);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // =========================
  // MONTHLY STATS
  // =========================
  @override
  Future<Either<Failure, MonthlyStatsEntity>> getMonthlyStats(
    DateTime month, {
    required String userId,
  }) async {
    try {
      final data = await remoteDataSource.getHistory(userId: userId);
      final records = data
          .map<AttendanceEntity>(
            (e) => AttendanceModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      final monthRecords = records
          .where(
            (r) => r.date.year == month.year && r.date.month == month.month,
          )
          .toList();

      final present = monthRecords
          .where((r) => r.status != 'absent' && r.status != 'on_leave')
          .length;
      final absent = monthRecords.where((r) => r.status == 'absent').length;
      final late = monthRecords.where((r) => r.status == 'late').length;
      final onLeave = monthRecords.where((r) => r.status == 'on_leave').length;
      final totalHours = monthRecords.fold<double>(
        0.0,
        (sum, r) => sum + r.workedHours,
      );
      final workingDays = monthRecords.where((r) => r.checkIn != null).length;
      final avgHours = workingDays > 0 ? totalHours / workingDays : 0.0;
      final overtimeHours = monthRecords.fold<double>(
            0.0,
        (sum, r) => sum + (r.workedHours > 8 ? r.workedHours - 8 : 0.0),
          );

      return Right(
        MonthlyStatsEntity(
          present: present,
          absent: absent,
          late: late,
          onLeave: onLeave,
          totalHours: totalHours,
          avgHours: avgHours,
          workingDays: workingDays,
          overtimeHours: overtimeHours,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> checkOut({
    required String userId,
  }) async {
    try {
      // Fetch today record to ensure we have current state
      final todayResult = await getTodayRecord(userId: userId);

      return await todayResult.fold((f) async => Left(f), (record) async {
        if (record == null) {
          return Left(ServerFailure('No active attendance found'));
        }

        print(
          'AttendanceRepositoryImpl.checkOut: user=$userId attendance=${record.id}',
        );
        final data = await remoteDataSource.checkOut(attendanceId: record.id);

        final attendance = AttendanceEntity(
          id: data['id']?.toString() ?? '',
          userId: data['user']?.toString() ?? '',
          date: DateTime.parse(data['check_in']),
          checkIn: DateTime.parse(data['check_in']),

          checkOut: data['checkout'] != null
              ? DateTime.parse(data['checkout'])
              : DateTime.now(),

          status: data['status']?.toString() ?? '',
          location: data['location']?.toString() ?? '',

          lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
          lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
        );

        _currentAttendance = attendance;

        return Right(attendance);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> startBreak(
    String breakType, {
    required String userId,
  }) async {
    try {
      // Fetch today record if cache is empty
      final todayResult = await getTodayRecord(userId: userId);

      return await todayResult.fold((f) async => Left(f), (record) async {
        if (record == null) {
          return Left(ServerFailure('No active attendance found'));
        }

        // Save break to backend
        final breakData = await remoteDataSource.startBreak(
        attendanceId: record.id,
        type: breakType,
      );

        // Refetch the full attendance record to get all breaks from backend
        final refreshResult = await getTodayRecord(userId: userId);

        return await refreshResult.fold((f) async => Left(f), (
          refreshed,
        ) async {
      if (refreshed == null) {
        return Left(ServerFailure('Failed to refresh attendance'));
      }

          final updatedAttendance = AttendanceEntity(
            id: refreshed.id,
            userId: refreshed.userId,
            date: refreshed.date,
            checkIn: refreshed.checkIn,
            checkOut: refreshed.checkOut,
            status: 'on_break',
            location: refreshed.location,
            lat: refreshed.lat,
            lng: refreshed.lng,
            breaks: refreshed.breaks,
          );

          _currentAttendance = updatedAttendance;

          return Right(updatedAttendance);
    });
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> endBreak({
    required String userId,
  }) async {
    try {
      // Fetch today record if cache is empty
      final todayResult = await getTodayRecord(userId: userId);

      return await todayResult.fold((f) async => Left(f), (record) async {
          if (record == null) {
            return Left(ServerFailure('No active attendance found'));
          }

        final breaks = List<BreakEntity>.from(record.breaks);
        final index = breaks.lastIndexWhere((b) => b.endTime == null);

        if (index == -1) {
          // No active break found locally; try querying backend
          final active = await remoteDataSource.getActiveBreak(
              attendanceId: record.id,
            );
          if (active == null) {
              return Left(ServerFailure('No active break found'));
            }

          // End the active break on backend
            await remoteDataSource.endBreak(
            breakId: active['id']?.toString() ?? '',
            );
          } else {
          // End the active break in local list
          final currentBreak = breaks[index];

          // Save break end time to backend
          await remoteDataSource.endBreak(breakId: currentBreak.id);
          }

        // Refetch the full attendance record to get all updated breaks from backend
        final refreshResult = await getTodayRecord(userId: userId);

        return await refreshResult.fold((f) async => Left(f), (
          refreshed,
        ) async {
          if (refreshed == null) {
            return Left(ServerFailure('Failed to refresh attendance'));
          }

          final updatedAttendance = AttendanceEntity(
            id: refreshed.id,
            userId: refreshed.userId,
            date: refreshed.date,
            checkIn: refreshed.checkIn,
            checkOut: refreshed.checkOut,
            status: 'checked_in',
            location: refreshed.location,
            lat: refreshed.lat,
            lng: refreshed.lng,
            breaks: refreshed.breaks,
          );

          _currentAttendance = updatedAttendance;

          return Right(updatedAttendance);
        });
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
