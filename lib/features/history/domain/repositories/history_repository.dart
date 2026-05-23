import 'package:checkmate/core/errors/failures.dart';
import 'package:checkmate/features/history/domain/entities/history_entity.dart';
import 'package:dartz/dartz.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoryEntity>>> getHistory();
}
