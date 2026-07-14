import 'package:checkmate/features/schedule/data/services/schedule_remote_data_source.dart';
import 'package:checkmate/features/schedule/domain/entities/schedule_entity.dart';
import 'package:checkmate/features/schedule/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  ScheduleRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ScheduleEntity>> getUserSchedule(String userId) =>
      remoteDataSource.getUserSchedule(userId);
}
