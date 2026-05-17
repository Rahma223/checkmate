import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

// ══════════════════════════════════════════════════════════════
// AUTH CUBIT
// ══════════════════════════════════════════════════════════════
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  AuthCubit(this._repo) : super(const AuthInitial());

  Future<void> checkAuth() async {
    final isIn = await _repo.isLoggedIn();
    if (isIn) {
      final result = await _repo.getProfile();
      result.fold(
        (_) => emit(const AuthUnauthenticated()),
        (u) => emit(AuthAuthenticated(u)),
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    final result = await _repo.login(email: email, password: password);
    result.fold(
      (f) => emit(AuthError(f.message)),
      (u) => emit(AuthAuthenticated(u)),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> updateProfile(UserEntity user) async {
    final result = await _repo.updateProfile(user);
    result.fold(
      (f) => emit(AuthError(f.message)),
      (u) => emit(AuthAuthenticated(u)),
    );
  }

  UserEntity? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;
}

// ══════════════════════════════════════════════════════════════
// HOME CUBIT
// ══════════════════════════════════════════════════════════════
class HomeState extends Equatable {
  final AttendanceEntity? todayRecord;
  final List<TaskEntity> tasks;
  final bool isLoading;
  final bool isSyncing;
  final bool isInsideGeofence;
  final String? error;
  final String actionInProgress; // '' | 'check_in' | 'check_out' | 'break'
  final int unreadNotifications;

  const HomeState({
    this.todayRecord,
    this.tasks = const [],
    this.isLoading = true,
    this.isSyncing = true,
    this.isInsideGeofence = true,
    this.error,
    this.actionInProgress = '',
    this.unreadNotifications = 0,
  });

  String get status => todayRecord?.status ?? 'not_checked_in';
  bool get isCheckedIn => status == 'checked_in';
  bool get isOnBreak => status == 'on_break';
  bool get isCheckedOut => status == 'checked_out';

  HomeState copyWith({
    AttendanceEntity? todayRecord,
    List<TaskEntity>? tasks,
    bool? isLoading,
    bool? isSyncing,
    bool? isInsideGeofence,
    String? error,
    String? actionInProgress,
    int? unreadNotifications,
    bool clearRecord = false,
  }) => HomeState(
    todayRecord: clearRecord ? null : (todayRecord ?? this.todayRecord),
    tasks: tasks ?? this.tasks,
    isLoading: isLoading ?? this.isLoading,
    isSyncing: isSyncing ?? this.isSyncing,
    isInsideGeofence: isInsideGeofence ?? this.isInsideGeofence,
    error: error ?? this.error,
    actionInProgress: actionInProgress ?? this.actionInProgress,
    unreadNotifications: unreadNotifications ?? this.unreadNotifications,
  );

  @override
  List<Object?> get props => [
    todayRecord,
    tasks,
    isLoading,
    isSyncing,
    isInsideGeofence,
    error,
    actionInProgress,
    unreadNotifications,
  ];
}

class HomeCubit extends Cubit<HomeState> {
  final AttendanceRepository _attendanceRepo;
  final TaskRepository _taskRepo;
  final NotificationRepository _notifRepo;

  HomeCubit(this._attendanceRepo, this._taskRepo, this._notifRepo)
    : super(const HomeState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, isSyncing: true));
    final results = await Future.wait([
      _attendanceRepo.getTodayRecord(),
      _taskRepo.getTasks(),
      _notifRepo.getAll(),
    ]);
    final record = results[0] as dynamic;
    final tasks = results[1] as dynamic;
    final notifs = results[2] as dynamic;

    final todayRecord = record.fold((_) => null, (r) => r);
    final taskList = tasks.fold(
      (_) => <TaskEntity>[],
      (r) => r as List<TaskEntity>,
    );
    final notifList = notifs.fold(
      (_) => <NotificationEntity>[],
      (r) => r as List<NotificationEntity>,
    );
    final unread = notifList.where((n) => !n.isRead).length;

    emit(
      state.copyWith(
        todayRecord: todayRecord,
        tasks: taskList,
        isLoading: false,
        unreadNotifications: unread,
      ),
    );

    await Future.delayed(const Duration(seconds: 3));
    emit(state.copyWith(isSyncing: false));
  }

  Future<void> checkIn() async {
    emit(state.copyWith(actionInProgress: 'check_in'));
    final result = await _attendanceRepo.checkIn(
      lat: 40.7484,
      lng: -73.9967,
      location: 'HQ - Tower A',
    );
    result.fold(
      (f) => emit(state.copyWith(error: f.message, actionInProgress: '')),
      (r) => emit(state.copyWith(todayRecord: r, actionInProgress: '')),
    );
  }

  Future<void> checkOut() async {
    emit(state.copyWith(actionInProgress: 'check_out'));
    final result = await _attendanceRepo.checkOut();
    result.fold(
      (f) => emit(state.copyWith(error: f.message, actionInProgress: '')),
      (r) => emit(state.copyWith(todayRecord: r, actionInProgress: '')),
    );
  }

  Future<void> startBreak(String type) async {
    emit(state.copyWith(actionInProgress: 'break'));
    final result = await _attendanceRepo.startBreak(type);
    result.fold(
      (f) => emit(state.copyWith(error: f.message, actionInProgress: '')),
      (r) => emit(state.copyWith(todayRecord: r, actionInProgress: '')),
    );
  }

  Future<void> endBreak() async {
    emit(state.copyWith(actionInProgress: 'break'));
    final result = await _attendanceRepo.endBreak();
    result.fold(
      (f) => emit(state.copyWith(error: f.message, actionInProgress: '')),
      (r) => emit(state.copyWith(todayRecord: r, actionInProgress: '')),
    );
  }

  void clearError() => emit(state.copyWith(error: ''));
}

// ══════════════════════════════════════════════════════════════
// SCHEDULE CUBIT
// ══════════════════════════════════════════════════════════════
class ScheduleState extends Equatable {
  final DateTime selectedMonth;
  final DateTime selectedDay;
  final List<ShiftEntity> shifts;
  final List<LeaveEntity> leaves;
  final bool isLoading;
  final String? error;

  ScheduleState({
    DateTime? selectedMonth,
    DateTime? selectedDay,
    this.shifts = const [],
    this.leaves = const [],
    this.isLoading = false,
    this.error,
  }) : selectedMonth =
           selectedMonth ?? DateTime(DateTime.now().year, DateTime.now().month),
       selectedDay = selectedDay ?? DateTime.now();

  List<ShiftEntity> get selectedDayShifts =>
      shifts.where((s) => DateUtils.isSameDay(s.date, selectedDay)).toList();

  bool hasShift(DateTime d) =>
      shifts.any((s) => DateUtils.isSameDay(s.date, d));
  bool hasLeave(DateTime d) =>
      leaves.any((l) => !d.isBefore(l.fromDate) && !d.isAfter(l.toDate));

  ScheduleState copyWith({
    DateTime? selectedMonth,
    DateTime? selectedDay,
    List<ShiftEntity>? shifts,
    List<LeaveEntity>? leaves,
    bool? isLoading,
    String? error,
  }) => ScheduleState(
    selectedMonth: selectedMonth ?? this.selectedMonth,
    selectedDay: selectedDay ?? this.selectedDay,
    shifts: shifts ?? this.shifts,
    leaves: leaves ?? this.leaves,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [
    selectedMonth,
    selectedDay,
    shifts,
    leaves,
    isLoading,
  ];
}

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _scheduleRepo;
  final LeaveRepository _leaveRepo;

  ScheduleCubit(this._scheduleRepo, this._leaveRepo) : super(ScheduleState()) {
    loadMonth(DateTime.now());
  }

  Future<void> loadMonth(DateTime month) async {
    emit(state.copyWith(isLoading: true, selectedMonth: month));
    final results = await Future.wait([
      _scheduleRepo.getMonthShifts(month),
      _leaveRepo.getLeaves(),
    ]);
    final shifts = (results[0] as dynamic).fold(
      (_) => <ShiftEntity>[],
      (r) => r,
    );
    final leaves = (results[1] as dynamic).fold(
      (_) => <LeaveEntity>[],
      (r) => r,
    );
    emit(state.copyWith(shifts: shifts, leaves: leaves, isLoading: false));
  }

  void selectDay(DateTime day) => emit(state.copyWith(selectedDay: day));
}

// ══════════════════════════════════════════════════════════════
// HISTORY CUBIT
// ══════════════════════════════════════════════════════════════
class HistoryState extends Equatable {
  final List<AttendanceEntity> records;
  final MonthlyStatsEntity? stats;
  final bool isLoading;
  final String filterStatus; // 'all' | status values
  final String? error;

  const HistoryState({
    this.records = const [],
    this.stats,
    this.isLoading = true,
    this.filterStatus = 'all',
    this.error,
  });

  List<AttendanceEntity> get filteredRecords => filterStatus == 'all'
      ? records
      : records.where((r) => r.status == filterStatus).toList();

  HistoryState copyWith({
    List<AttendanceEntity>? records,
    MonthlyStatsEntity? stats,
    bool? isLoading,
    String? filterStatus,
    String? error,
  }) => HistoryState(
    records: records ?? this.records,
    stats: stats ?? this.stats,
    isLoading: isLoading ?? this.isLoading,
    filterStatus: filterStatus ?? this.filterStatus,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [records, stats, isLoading, filterStatus];
}

class HistoryCubit extends Cubit<HistoryState> {
  final AttendanceRepository _repo;
  HistoryCubit(this._repo) : super(const HistoryState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final results = await Future.wait([
      _repo.getHistory(),
      _repo.getMonthlyStats(DateTime.now()),
    ]);
    final records = (results[0] as dynamic).fold(
      (_) => <AttendanceEntity>[],
      (r) => r,
    );
    final stats = (results[1] as dynamic).fold((_) => null, (r) => r);
    emit(state.copyWith(records: records, stats: stats, isLoading: false));
  }

  void setFilter(String status) => emit(state.copyWith(filterStatus: status));
}

// ══════════════════════════════════════════════════════════════
// TASK CUBIT
// ══════════════════════════════════════════════════════════════
class TaskState extends Equatable {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final String filter; // 'all' | task status values
  final String? error;

  const TaskState({
    this.tasks = const [],
    this.isLoading = true,
    this.filter = 'all',
    this.error,
  });

  List<TaskEntity> get filtered =>
      filter == 'all' ? tasks : tasks.where((t) => t.status == filter).toList();

  TaskState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    String? filter,
    String? error,
  }) => TaskState(
    tasks: tasks ?? this.tasks,
    isLoading: isLoading ?? this.isLoading,
    filter: filter ?? this.filter,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [tasks, isLoading, filter];
}

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repo;
  TaskCubit(this._repo) : super(const TaskState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.getTasks();
    result.fold(
      (f) => emit(state.copyWith(error: f.message, isLoading: false)),
      (t) => emit(state.copyWith(tasks: t, isLoading: false)),
    );
  }

  void setFilter(String f) => emit(state.copyWith(filter: f));

  Future<void> updateStatus(String taskId, String status) async {
    final result = await _repo.updateStatus(taskId, status);
    result.fold((f) => emit(state.copyWith(error: f.message)), (updated) {
      final tasks = state.tasks
          .map((t) => t.id == taskId ? updated : t)
          .toList();
      emit(state.copyWith(tasks: tasks));
    });
  }
}

// ══════════════════════════════════════════════════════════════
// TEAM CUBIT
// ══════════════════════════════════════════════════════════════
class TeamState extends Equatable {
  final List<TeamMemberEntity> members;
  final bool isLoading;
  final String? error;

  const TeamState({this.members = const [], this.isLoading = true, this.error});

  TeamState copyWith({
    List<TeamMemberEntity>? members,
    bool? isLoading,
    String? error,
  }) => TeamState(
    members: members ?? this.members,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );

  @override
  List<Object?> get props => [members, isLoading];
}

class TeamCubit extends Cubit<TeamState> {
  final TeamRepository _repo;
  TeamCubit(this._repo) : super(const TeamState()) {
    load();
  }

  Future<void> load() async {
    emit(const TeamState(isLoading: true));
    final result = await _repo.getTeam();
    result.fold(
      (f) => emit(TeamState(isLoading: false, error: f.message)),
      (m) => emit(TeamState(members: m, isLoading: false)),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// NOTIFICATION CUBIT
// ══════════════════════════════════════════════════════════════
class NotificationState extends Equatable {
  final List<NotificationEntity> items;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.items = const [],
    this.isLoading = true,
    this.error,
  });

  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationEntity>? items,
    bool? isLoading,
    String? error,
  }) => NotificationState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );

  @override
  List<Object?> get props => [items, isLoading];
}

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repo;
  NotificationCubit(this._repo) : super(const NotificationState()) {
    load();
  }

  Future<void> load() async {
    final result = await _repo.getAll();
    result.fold(
      (f) => emit(NotificationState(isLoading: false, error: f.message)),
      (n) => emit(NotificationState(items: n, isLoading: false)),
    );
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    final items = state.items
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    emit(state.copyWith(items: items));
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    final items = state.items.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(items: items));
  }
}

// ══════════════════════════════════════════════════════════════
// PROFILE / LEAVE CUBIT
// ══════════════════════════════════════════════════════════════
class ProfileState extends Equatable {
  final List<LeaveEntity> leaves;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.leaves = const [],
    this.isLoading = true,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    List<LeaveEntity>? leaves,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? successMessage,
  }) => ProfileState(
    leaves: leaves ?? this.leaves,
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    error: error,
    successMessage: successMessage,
  );

  @override
  List<Object?> get props => [
    leaves,
    isLoading,
    isSubmitting,
    error,
    successMessage,
  ];
}

class ProfileCubit extends Cubit<ProfileState> {
  final LeaveRepository _leaveRepo;
  ProfileCubit(this._leaveRepo) : super(const ProfileState()) {
    loadLeaves();
  }

  Future<void> loadLeaves() async {
    emit(state.copyWith(isLoading: true));
    final result = await _leaveRepo.getLeaves();
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (l) => emit(state.copyWith(leaves: l, isLoading: false)),
    );
  }

  Future<void> submitLeave({
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    emit(state.copyWith(isSubmitting: true));
    final result = await _leaveRepo.submitLeave(
      type: type,
      fromDate: fromDate,
      toDate: toDate,
      reason: reason,
    );
    result.fold(
      (f) => emit(state.copyWith(isSubmitting: false, error: f.message)),
      (l) => emit(
        state.copyWith(
          isSubmitting: false,
          leaves: [l, ...state.leaves],
          successMessage: 'Leave request submitted',
        ),
      ),
    );
  }

  Future<void> cancelLeave(String id) async {
    final result = await _leaveRepo.cancelLeave(id);
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (_) => emit(
        state.copyWith(leaves: state.leaves.where((l) => l.id != id).toList()),
      ),
    );
  }

  void clearMessages() => emit(state.copyWith());
}
