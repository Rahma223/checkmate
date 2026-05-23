import 'package:checkmate/core/errors/failures.dart';
import 'package:checkmate/features/history/data/datasources/history_remote_data_source.dart';
import 'package:checkmate/features/history/data/models/history_model.dart';
import 'package:checkmate/features/history/domain/entities/history_entity.dart';
import 'package:checkmate/features/history/domain/repositories/history_repository.dart';
import 'package:dartz/dartz.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<HistoryEntity>>> getHistory() async {
    try {
      final data = await remoteDataSource.getHistory();

      final history = data.map((e) => HistoryModel.fromJson(e)).toList();

      return Right(history);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
