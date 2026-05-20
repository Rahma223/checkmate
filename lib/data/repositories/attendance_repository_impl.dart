import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../services/attendance_remote_data_source.dart';

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

        checkOut: data['check_out'] != null
            ? DateTime.parse(data['check_out'])
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

  Future<Either<Failure, AttendanceEntity?>> getTodayRecord() async {
    return Right(_currentAttendance);
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getHistory({
    int page = 0,
    int limit = 30,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, MonthlyStatsEntity>> getMonthlyStats(
    DateTime month,
  ) async {
    return Right(
      MonthlyStatsEntity(
        present: 0,
        absent: 0,
        late: 0,
        onLeave: 0,
        totalHours: 0,
        avgHours: 0,
        workingDays: 0,
        overtimeHours: 0,
      ),
    );
  }

  @override
  Future<Either<Failure, AttendanceEntity>> checkOut() async {
    try {
      final todayResult = await getTodayRecord();

      return await todayResult.fold((f) async => Left(f), (record) async {
        if (record == null) {
          return Left(ServerFailure('No active attendance found'));
        }

        final data = await remoteDataSource.checkOut(
          attendanceId: int.parse(record.id),
        );

        final attendance = AttendanceEntity(
          id: data['id']?.toString() ?? '',
          userId: data['user']?.toString() ?? '',
          date: DateTime.parse(data['check_in']),
          checkIn: DateTime.parse(data['check_in']),

          checkOut: data['check_out'] != null
              ? DateTime.parse(data['check_out'])
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
  String breakType,
) async {
  try {
    if (_currentAttendance == null) {
      return Left(
        ServerFailure('No active attendance found'),
      );
    }

    final breaks = List<BreakEntity>.from(
      _currentAttendance!.breaks,
    );

    breaks.add(
      BreakEntity(
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

    return Left(
      ServerFailure(e.toString()),
    );
  }
}

@override
Future<Either<Failure, AttendanceEntity>> endBreak() async {
  try {

    if (_currentAttendance == null) {
      return Left(
        ServerFailure('No active attendance found'),
      );
    }

    final breaks = List<BreakEntity>.from(
      _currentAttendance!.breaks,
    );

    final index = breaks.lastIndexWhere(
      (b) => b.endTime == null,
    );

    if (index == -1) {
      return Left(
        ServerFailure('No active break found'),
      );
    }

    final currentBreak = breaks[index];

    breaks[index] = BreakEntity(
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

    return Left(
      ServerFailure(e.toString()),
    );
  }
}

}
