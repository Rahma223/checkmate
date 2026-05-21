import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

class HomeState extends Equatable {
  final AttendanceEntity? todayRecord;
  final List<TaskEntity> tasks;
  final bool isLoading;
  final bool isSyncing;
  final bool isInsideGeofence;
  final String? error;
  final String actionInProgress;
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
  final AuthCubit _authCubit;

  HomeCubit(
    this._attendanceRepo,
    this._taskRepo,
    this._notifRepo,
    this._authCubit,
  ) : super(const HomeState()) {
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

    final authState = _authCubit.state;

    if (authState is! AuthAuthenticated) {
      emit(state.copyWith(error: 'User not logged in', actionInProgress: ''));
      return;
    }

    final userId = authState.user.id;

    final result = await _attendanceRepo.checkIn(
      userId: userId,
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
