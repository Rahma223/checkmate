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

      final attendance = AttendanceEntity(
        id: data['id']?.toString() ?? '',
        userId: data['user']?.toString() ?? '',
        date: DateTime.parse(data['check_in']),
        checkIn: DateTime.parse(data['check_in']),

        checkOut: data['checkout'] != null
            ? DateTime.parse(data['checkout'])
            : null,

        status: data['status']?.toString() ?? '',
        location: data['location']?.toString() ?? '',

        lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      );
      _currentAttendance = attendance;
      return Right(attendance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity?>> getTodayRecord() async {
    return Right(_currentAttendance);
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getHistory({
    required String userId,
  }) async {
    try {
      final data = await remoteDataSource.getHistory(userId: userId);

      final history = data
          .map<AttendanceEntity>(
            (e) => AttendanceModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      return Right(history);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

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
  Future<Either<Failure, AttendanceEntity>> checkOut() async {
    try {
      final todayResult = await getTodayRecord();

      return await todayResult.fold((f) async => Left(f), (record) async {
        if (record == null) {
          return Left(ServerFailure('No active attendance found'));
        }

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
  Future<Either<Failure, AttendanceEntity>> startBreak(String breakType) async {
    try {
      if (_currentAttendance == null) {
        return Left(ServerFailure('No active attendance found'));
      }

      final breaks = List<BreakEntity>.from(_currentAttendance!.breaks);

      breaks.add(
        BreakEntity(
          id: DateTime.now().toIso8601String(),
          type: breakType,
          startTime: DateTime.now(),
        ),
      );

      final updatedAttendance = AttendanceEntity(
        id: _currentAttendance!.id,
        userId: _currentAttendance!.userId,
        date: _currentAttendance!.date,
        checkIn: _currentAttendance!.checkIn,
        checkOut: _currentAttendance!.checkOut,
        status: 'on_break',
        location: _currentAttendance!.location,
        lat: _currentAttendance!.lat,
        lng: _currentAttendance!.lng,
        breaks: breaks,
      );

      _currentAttendance = updatedAttendance;

      return Right(updatedAttendance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> endBreak() async {
    try {
      if (_currentAttendance == null) {
        return Left(ServerFailure('No active attendance found'));
      }

      final breaks = List<BreakEntity>.from(_currentAttendance!.breaks);

      final index = breaks.lastIndexWhere((b) => b.endTime == null);

      if (index == -1) {
        return Left(ServerFailure('No active break found'));
      }

      final currentBreak = breaks[index];

      breaks[index] = BreakEntity(
        id: currentBreak.id,
        type: currentBreak.type,
        startTime: currentBreak.startTime,
        endTime: DateTime.now(),
      );

      final updatedAttendance = AttendanceEntity(
        id: _currentAttendance!.id,
        userId: _currentAttendance!.userId,
        date: _currentAttendance!.date,
        checkIn: _currentAttendance!.checkIn,
        checkOut: _currentAttendance!.checkOut,
        status: 'checked_in',
        location: _currentAttendance!.location,
        lat: _currentAttendance!.lat,
        lng: _currentAttendance!.lng,
        breaks: breaks,
      );

      _currentAttendance = updatedAttendance;

      return Right(updatedAttendance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
