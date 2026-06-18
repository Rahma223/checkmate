import 'package:dartz/dartz.dart';
import 'package:checkmate/core/errors/failures.dart';
import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceEntity?>> getTodayRecord({
    required String userId,
  });
  Future<Either<Failure, List<AttendanceEntity>>> getHistory({
    required String userId,
    String? status,
  });
  Future<Either<Failure, MonthlyStatsEntity>> getMonthlyStats(
    DateTime month, {
    required String userId,
  });
  Future<Either<Failure, AttendanceEntity>> checkIn({
    required String userId,
    required double lat,
    required double lng,
    required String location,
  });
  Future<Either<Failure, AttendanceEntity>> checkOut({required String userId});
  Future<Either<Failure, AttendanceEntity>> startBreak(
    String breakType, {
    required String userId,
  });
  Future<Either<Failure, AttendanceEntity>> endBreak({required String userId});
}
