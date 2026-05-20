import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/entities.dart';

// ─────────────────────────────────────────────────────────────
// AUTH
// ─────────────────────────────────────────────────────────────
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({required String email, required String password});
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, void>>       logout();
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user);
  Future<bool>                        isLoggedIn();
}

// ─────────────────────────────────────────────────────────────
// ATTENDANCE
// ─────────────────────────────────────────────────────────────
abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceEntity?>>    getTodayRecord();
  Future<Either<Failure, List<AttendanceEntity>>> getHistory({int page = 0, int limit = 30});
  Future<Either<Failure, MonthlyStatsEntity>>   getMonthlyStats(DateTime month);
 Future<Either<Failure, AttendanceEntity>> checkIn({
  required String userId,
  required double lat,
  required double lng,
  required String location,
});
  Future<Either<Failure, AttendanceEntity>>     checkOut();
  Future<Either<Failure, AttendanceEntity>>     startBreak(String breakType);
  Future<Either<Failure, AttendanceEntity>>     endBreak();
}

// ─────────────────────────────────────────────────────────────
// TASK
// ─────────────────────────────────────────────────────────────
abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, TaskEntity>>       updateStatus(String taskId, String status);
}

// ─────────────────────────────────────────────────────────────
// SCHEDULE
// ─────────────────────────────────────────────────────────────
abstract class ScheduleRepository {
  Future<Either<Failure, List<ShiftEntity>>> getMonthShifts(DateTime month);
}

// ─────────────────────────────────────────────────────────────
// LEAVE
// ─────────────────────────────────────────────────────────────
abstract class LeaveRepository {
  Future<Either<Failure, List<LeaveEntity>>> getLeaves();
  Future<Either<Failure, LeaveEntity>>       submitLeave({
    required String   type,
    required DateTime fromDate,
    required DateTime toDate,
    required String   reason,
  });
  Future<Either<Failure, void>> cancelLeave(String leaveId);
}

// ─────────────────────────────────────────────────────────────
// TEAM
// ─────────────────────────────────────────────────────────────
abstract class TeamRepository {
  Future<Either<Failure, List<TeamMemberEntity>>> getTeam();
}

// ─────────────────────────────────────────────────────────────
// NOTIFICATION
// ─────────────────────────────────────────────────────────────
abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getAll();
  Future<Either<Failure, void>> markRead(String id);
  Future<Either<Failure, void>> markAllRead();
}
