import 'package:checkmate/features/schedule/domain/entities/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> getUserSchedule(String userId);
}
