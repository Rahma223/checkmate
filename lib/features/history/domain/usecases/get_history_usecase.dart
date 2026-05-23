import 'package:checkmate/core/errors/failures.dart';
import 'package:checkmate/features/history/domain/entities/history_entity.dart';
import 'package:checkmate/features/history/domain/repositories/history_repository.dart';
import 'package:dartz/dartz.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase(this.repository);

  Future<Either<Failure, List<HistoryEntity>>> call() {
    return repository.getHistory();
  }
}
