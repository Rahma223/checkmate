import 'package:dartz/dartz.dart';
import 'package:checkmate/core/errors/failures.dart';
import '../entities/shift_entity.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, List<ShiftEntity>>> getMonthShifts(DateTime month);
}
