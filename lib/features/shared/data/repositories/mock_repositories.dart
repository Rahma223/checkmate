import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:checkmate/core/errors/failures.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

// This file contains mock implementations of all repositories for testing and development purposes.
class MockAuthRepository implements AuthRepository {
  UserEntity? _current;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email.isEmpty || password.length < 6) {
      return const Left(AuthFailure('Invalid credentials.'));
    }
    _current = _mockUser();
    return Right(_current!);
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _current ??= _mockUser();
    return Right(_current!);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    _current = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user) async {
    await Future.delayed(const Duration(seconds: 1));
    _current = user;
    return Right(_current!);
  }

  @override
  Future<bool> isLoggedIn() async => false;
  UserEntity _mockUser() => const UserEntity(
    id: 'usr_001',
    name: 'Alex Morgan',
    email: 'rahma@test.com',
    department: 'Engineering',
    position: 'Senior Developer',
    employeeId: 'EMP-2024-001',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    phone: '+1 (555) 012-3456',
    shiftStart: '09:00',
    shiftEnd: '17:30',
    workLocation: 'HQ - Tower A',
    totalLeaves: 21,
    usedLeaves: 5,
  );
}

class MockAttendanceRepository implements AttendanceRepository {
  AttendanceEntity? _today;
  final List<AttendanceEntity> _history = _buildHistory();

  @override
  Future<Either<Failure, AttendanceEntity?>> getTodayRecord({
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Right(_today);
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getHistory({
    required String userId,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (status == null || status == 'all') return Right(_history);
    final filtered = _history.where((r) => r.status == status).toList();
    return Right(filtered);
  }

  @override
  Future<Either<Failure, MonthlyStatsEntity>> getMonthlyStats(
    DateTime month, {
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const Right(
      MonthlyStatsEntity(
        present: 18,
        absent: 1,
        late: 2,
        onLeave: 2,
        totalHours: 153.5,
        avgHours: 8.5,
        workingDays: 23,
        overtimeHours: 6.5,
      ),
    );
  }

  @override
  Future<Either<Failure, AttendanceEntity>> checkIn({
    required String userId,
    required double lat,
    required double lng,
    required String location,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    _today = AttendanceEntity(
      id: 'att_today',
      userId: userId,
      date: now,
      checkIn: now,
      status: 'checked_in',
      location: location,
      lat: lat,
      lng: lng,
    );
    return Right(_today!);
  }

  @override
  Future<Either<Failure, AttendanceEntity>> checkOut({
    required String userId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _today = _today!.copyWith(checkOut: DateTime.now(), status: 'checked_out');
    return Right(_today!);
  }

  @override
  Future<Either<Failure, AttendanceEntity>> startBreak(
    String breakType, {
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final breaks = List<BreakEntity>.from(_today!.breaks)
      ..add(
        BreakEntity(
          id: DateTime.now().toIso8601String(),
          startTime: DateTime.now(),
          type: breakType,
        ),
      );
    _today = _today!.copyWith(status: 'on_break', breaks: breaks);
    return Right(_today!);
  }

  @override
  Future<Either<Failure, AttendanceEntity>> endBreak({
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final breaks = _today!.breaks
        .map(
          (b) => b.isActive
              ? BreakEntity(
                  id: b.id,
                  startTime: b.startTime,
                  endTime: DateTime.now(),
                  type: b.type,
                )
              : b,
        )
        .toList();
    _today = _today!.copyWith(status: 'checked_in', breaks: breaks);
    return Right(_today!);
  }

  static List<AttendanceEntity> _buildHistory() {
    final now = DateTime.now();
    final list = <AttendanceEntity>[];
    var counter = 1;
    for (int i = 1; i <= 45; i++) {
      final date = now.subtract(Duration(days: i));
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday)
        continue;
      final ci = DateTime(date.year, date.month, date.day, 8, 40 + (i % 30));
      final co = DateTime(date.year, date.month, date.day, 17, 25 + (i % 20));
      final status = counter == 3
          ? 'absent'
          : counter == 8
          ? 'on_leave'
          : ci.hour >= 9 && ci.minute > 10
          ? 'late'
          : 'checked_out';
      list.add(
        AttendanceEntity(
          id: 'att_$counter',
          userId: 'usr_001',
          date: date,
          checkIn: status == 'absent' || status == 'on_leave' ? null : ci,
          checkOut: status == 'absent' || status == 'on_leave' ? null : co,
          status: status,
          location: 'HQ - Tower A',
        ),
      );
      counter++;
    }
    return list;
  }
}

class MockTaskRepository implements TaskRepository {
  final List<TaskEntity> _tasks = [
    TaskEntity(
      id: 't_001',
      title: 'API Integration Review',
      description:
          'Review and test all payment API endpoints for the new checkout flow. Ensure error states are handled gracefully.',
      status: 'in_progress',
      priority: 'high',
      assignedBy: 'Sarah Chen',
      projectName: 'Checkout Revamp',
      dueDate: DateTime.now().add(const Duration(hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      progress: 0.6,
      tags: ['Backend', 'API'],
    ),
    TaskEntity(
      id: 't_002',
      title: 'Dashboard UI Refinements',
      description:
          'Polish the analytics dashboard according to design system feedback from last sprint review.',
      status: 'pending',
      priority: 'medium',
      assignedBy: 'James Liu',
      projectName: 'Analytics Platform',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      progress: 0.0,
      tags: ['Frontend', 'UI'],
    ),
    TaskEntity(
      id: 't_003',
      title: 'Write Unit Tests — Auth Module',
      description:
          'Increase test coverage to 80% for authentication flows including OAuth and 2FA.',
      status: 'pending',
      priority: 'medium',
      assignedBy: 'Sarah Chen',
      projectName: 'Core Infrastructure',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      progress: 0.0,
      tags: ['Testing', 'Auth'],
    ),
    TaskEntity(
      id: 't_004',
      title: 'Fix Report Export Bug',
      description:
          'CSV export crashes when date range exceeds 90 days. Root cause appears to be a memory limit in the serializer.',
      status: 'overdue',
      priority: 'high',
      assignedBy: 'Marcus R.',
      projectName: 'Reporting',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      progress: 0.2,
      tags: ['Bug', 'Reports'],
    ),
    TaskEntity(
      id: 't_005',
      title: 'Database Schema Migration',
      description:
          'Migrate legacy tables to the new normalized schema. Downtime window: Sunday 02:00–04:00 AM.',
      status: 'completed',
      priority: 'high',
      assignedBy: 'Sarah Chen',
      projectName: 'Core Infrastructure',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      progress: 1.0,
      tags: ['Database'],
    ),
    TaskEntity(
      id: 't_006',
      title: 'Security Audit Preparation',
      description:
          'Prepare documentation and access logs for Q4 security audit scheduled next week.',
      status: 'pending',
      priority: 'low',
      assignedBy: 'DevOps Team',
      projectName: 'Security',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      progress: 0.0,
      tags: ['Security', 'Docs'],
    ),
  ];

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Right(List.from(_tasks));
  }

  @override
  Future<Either<Failure, TaskEntity>> updateStatus(
    String taskId,
    String status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return const Left(NotFoundFailure('Task not found'));
    final updated = TaskEntity(
      id: _tasks[idx].id,
      title: _tasks[idx].title,
      description: _tasks[idx].description,
      status: status,
      priority: _tasks[idx].priority,
      assignedBy: _tasks[idx].assignedBy,
      dueDate: _tasks[idx].dueDate,
      createdAt: _tasks[idx].createdAt,
      projectName: _tasks[idx].projectName,
      progress: status == 'completed' ? 1.0 : _tasks[idx].progress,
      tags: _tasks[idx].tags,
    );
    _tasks[idx] = updated;
    return Right(updated);
  }
}

class MockScheduleRepository implements ScheduleRepository {
  @override
  Future<Either<Failure, List<ShiftEntity>>> getMonthShifts(
    DateTime month,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final shifts = <ShiftEntity>[];
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    for (int d = 1; d <= days; d++) {
      final date = DateTime(month.year, month.month, d);
      if (date.weekday >= 6) continue;
      shifts.add(
        ShiftEntity(
          id: 'shift_${month.month}_$d',
          date: date,
          startTime: '09:00',
          endTime: d % 5 == 0 ? '18:30' : '17:30',
          location: d % 8 == 0 ? 'Remote' : 'HQ - Tower A',
          type: d % 8 == 0
              ? 'remote'
              : d % 5 == 0
              ? 'overtime'
              : 'regular',
        ),
      );
    }
    return Right(shifts);
  }
}

class MockLeaveRepository implements LeaveRepository {
  final List<LeaveEntity> _leaves = [
    LeaveEntity(
      id: 'lv_001',
      userId: 'usr_001',
      type: 'Annual Leave',
      fromDate: DateTime.now().add(const Duration(days: 10)),
      toDate: DateTime.now().add(const Duration(days: 14)),
      reason: 'Family vacation abroad.',
      status: 'approved',
      approverName: 'Sarah Chen',
      approverNote: 'Approved. Have a great trip!',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    LeaveEntity(
      id: 'lv_002',
      userId: 'usr_001',
      type: 'Sick Leave',
      fromDate: DateTime.now().subtract(const Duration(days: 7)),
      toDate: DateTime.now().subtract(const Duration(days: 6)),
      reason: 'Fever and throat infection.',
      status: 'approved',
      approverName: 'Sarah Chen',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    LeaveEntity(
      id: 'lv_003',
      userId: 'usr_001',
      type: 'Personal Leave',
      fromDate: DateTime.now().add(const Duration(days: 3)),
      toDate: DateTime.now().add(const Duration(days: 3)),
      reason: 'Personal errands.',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  @override
  Future<Either<Failure, void>> createLeave(LeaveEntity leave) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _leaves.insert(0, leave);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<LeaveEntity>>> getUserLeaves(
    String userId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(_leaves.where((leave) => leave.userId == userId).toList());
  }

  @override
  Future<Either<Failure, LeaveEntity>> submitLeave({
    required String userId,
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final leave = LeaveEntity(
      id: 'lv_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      fromDate: fromDate,
      toDate: toDate,
      reason: reason,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _leaves.insert(0, leave);
    return Right(leave);
  }

  @override
  Future<Either<Failure, void>> cancelLeave(String leaveId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _leaves.removeWhere((l) => l.id == leaveId);
    return const Right(null);
  }
}

class MockTeamRepository implements TeamRepository {
  @override
  Future<Either<Failure, List<TeamMemberEntity>>> getTeam() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const Right([
      TeamMemberEntity(
        id: 'tm_001',
        name: 'Sarah Chen',
        position: 'Engineering Manager',
        department: 'Engineering',
        avatarUrl: 'https://i.pravatar.cc/150?img=47',
        status: 'checked_in',
        checkInTime: '08:52 AM',
        workLocation: 'HQ - Tower A',
      ),
      TeamMemberEntity(
        id: 'tm_002',
        name: 'James Liu',
        position: 'Product Designer',
        department: 'Design',
        avatarUrl: 'https://i.pravatar.cc/150?img=11',
        status: 'checked_in',
        checkInTime: '09:05 AM',
        workLocation: 'Remote',
      ),
      TeamMemberEntity(
        id: 'tm_003',
        name: 'Priya Sharma',
        position: 'Backend Developer',
        department: 'Engineering',
        avatarUrl: 'https://i.pravatar.cc/150?img=25',
        status: 'on_leave',
      ),
      TeamMemberEntity(
        id: 'tm_004',
        name: 'Marcus Robinson',
        position: 'QA Engineer',
        department: 'Engineering',
        avatarUrl: 'https://i.pravatar.cc/150?img=15',
        status: 'checked_in',
        checkInTime: '08:47 AM',
        workLocation: 'HQ - Tower A',
      ),
      TeamMemberEntity(
        id: 'tm_005',
        name: 'Elena Kozlov',
        position: 'Frontend Developer',
        department: 'Engineering',
        avatarUrl: 'https://i.pravatar.cc/150?img=32',
        status: 'late',
        checkInTime: '09:41 AM',
        workLocation: 'HQ - Tower A',
      ),
      TeamMemberEntity(
        id: 'tm_006',
        name: 'David Park',
        position: 'DevOps Engineer',
        department: 'Infrastructure',
        avatarUrl: 'https://i.pravatar.cc/150?img=8',
        status: 'absent',
      ),
      TeamMemberEntity(
        id: 'tm_007',
        name: 'Lena Müller',
        position: 'Data Analyst',
        department: 'Analytics',
        avatarUrl: 'https://i.pravatar.cc/150?img=44',
        status: 'checked_in',
        checkInTime: '09:00 AM',
        workLocation: 'HQ - Tower B',
      ),
    ]);
  }
}

class MockNotificationRepository implements NotificationRepository {
  final List<NotificationEntity> _items = [
    NotificationEntity(
      id: 'n_001',
      title: 'Shift Reminder',
      body: 'Your shift starts in 30 minutes at HQ - Tower A.',
      type: 'shift',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    NotificationEntity(
      id: 'n_002',
      title: 'Leave Approved',
      body:
          'Your annual leave (Oct 30 – Nov 3) has been approved by Sarah Chen.',
      type: 'leave',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    NotificationEntity(
      id: 'n_003',
      title: 'New Task Assigned',
      body:
          'James Liu assigned you "Dashboard UI Refinements" — due in 2 days.',
      type: 'task',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationEntity(
      id: 'n_004',
      title: 'Team Update',
      body: 'Engineering standup moved to 10:00 AM today.',
      type: 'team',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: true,
    ),
    NotificationEntity(
      id: 'n_005',
      title: 'Payroll Processed',
      body: 'Your October salary has been credited to your account.',
      type: 'payroll',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationEntity(
      id: 'n_006',
      title: 'Task Overdue',
      body: '"Fix Report Export Bug" is now overdue. Please update the status.',
      type: 'task',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<Either<Failure, List<NotificationEntity>>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(List.from(_items));
  }

  @override
  Future<Either<Failure, void>> markRead(String id) async {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1) _items[idx] = _items[idx].copyWith(isRead: true);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> markAllRead() async {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    return const Right(null);
  }
}
