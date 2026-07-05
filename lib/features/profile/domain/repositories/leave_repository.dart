import 'package:dartz/dartz.dart';
import 'package:checkmate/core/errors/failures.dart';
import '../entities/leave_entity.dart';

abstract class LeaveRepository {
  Future<Either<Failure, void>> createLeave(LeaveEntity leave);
  Future<Either<Failure, List<LeaveEntity>>> getUserLeaves(String userId);
  Future<Either<Failure, LeaveEntity>> submitLeave({
    required String userId,
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  });
  Future<Either<Failure, void>> cancelLeave(String leaveId);
}
