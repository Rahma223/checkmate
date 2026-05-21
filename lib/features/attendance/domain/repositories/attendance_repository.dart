import 'package:dartz/dartz.dart';
import 'package:checkmate/core/errors/failures.dart';
import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceEntity?>> getTodayRecord();
  Future<Either<Failure, List<AttendanceEntity>>> getHistory({
    int page = 0,
    int limit = 30,
  });
  Future<Either<Failure, MonthlyStatsEntity>> getMonthlyStats(DateTime month);
  Future<Either<Failure, AttendanceEntity>> checkIn({
    required String userId,
    required double lat,
    required double lng,
    required String location,
  });
  Future<Either<Failure, AttendanceEntity>> checkOut();
  Future<Either<Failure, AttendanceEntity>> startBreak(String breakType);
  Future<Either<Failure, AttendanceEntity>> endBreak();
}
