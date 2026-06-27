import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/core/services/geofence_service.dart';
import 'package:checkmate/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

class HomeState extends Equatable {
  final AttendanceEntity? todayRecord;
  final MonthlyStatsEntity? monthlyStats;
  final List<TaskEntity> tasks;
  final bool isLoading;
  final bool isSyncing;
  final bool isInsideGeofence;
  final String? error;
  final String actionInProgress;
  final int unreadNotifications;

  const HomeState({
    this.todayRecord,
    this.monthlyStats,
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
    MonthlyStatsEntity? monthlyStats,
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
    monthlyStats: monthlyStats ?? this.monthlyStats,
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
    monthlyStats,
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
  final GeofenceService _geofenceService;
  late final StreamSubscription _authSubscription;

  HomeCubit(
    this._attendanceRepo,
    this._taskRepo,
    this._notifRepo,
    this._authCubit,
    this._geofenceService,
  ) : super(const HomeState()) {
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        load();
      } else if (authState is AuthUnauthenticated) {
        // Clear attendance cache and reset home state when user logs out
        try {
          // AttendanceRepositoryImpl exposes clearCache()
          if (_attendanceRepo is dynamic) {
            try {
              (_attendanceRepo as dynamic).clearCache();
            } catch (_) {}
          }
        } catch (_) {}

        emit(const HomeState());
      }
    });

    if (_authCubit.state is AuthAuthenticated) {
      load();
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, isSyncing: true));

    final authState = _authCubit.state;
    if (authState is! AuthAuthenticated) {
      emit(state.copyWith(isLoading: false, isSyncing: false));
      return;
    }

    print('HomeCubit.load: user=${authState.user.id}');

    final results = await Future.wait([
      _attendanceRepo.getTodayRecord(userId: authState.user.id),
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
    print(
      'HomeCubit.load: todayRecord=${todayRecord?.id}, breaks=${todayRecord?.breaks.length ?? 0}',
    );

    // Fetch monthly stats for authenticated user
    final statsResult = await _attendanceRepo.getMonthlyStats(
      DateTime.now(),
      userId: authState.user.id,
    );
    statsResult.fold((_) => null, (r) => emit(state.copyWith(monthlyStats: r)));

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

    try {
      final isInsideGeofence = await _geofenceService.isInsideGeofence(
        authState.user,
      );

      if (!isInsideGeofence) {
        emit(
          state.copyWith(
            isInsideGeofence: false,
            error: 'You are outside the allowed work area.',
            actionInProgress: '',
          ),
        );
        return;
      }

      emit(state.copyWith(isInsideGeofence: true));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(error: message, actionInProgress: ''));
      return;
    }

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
    emit(state.copyWith(actionInProgress: 'checkout'));

    final authState = _authCubit.state;
    if (authState is! AuthAuthenticated) {
      emit(state.copyWith(error: 'User not logged in', actionInProgress: ''));
      return;
    }

    final result = await _attendanceRepo.checkOut(userId: authState.user.id);

    result.fold(
      (f) => emit(state.copyWith(error: f.message, actionInProgress: '')),
      (r) async {
        await load();
        emit(state.copyWith(todayRecord: r, actionInProgress: ''));
      },
    );
  }

  Future<void> startBreak(String type) async {
    emit(state.copyWith(actionInProgress: 'break'));

    final authState = _authCubit.state;
    if (authState is! AuthAuthenticated) {
      emit(state.copyWith(error: 'User not logged in', actionInProgress: ''));
      return;
    }

    final result = await _attendanceRepo.startBreak(
      type,
      userId: authState.user.id,
    );
    result.fold(
      (f) => emit(state.copyWith(error: f.message, actionInProgress: '')),
      (r) => emit(state.copyWith(todayRecord: r, actionInProgress: '')),
    );
  }

  Future<void> endBreak() async {
    emit(state.copyWith(actionInProgress: 'break'));

    final authState = _authCubit.state;
    if (authState is! AuthAuthenticated) {
      emit(state.copyWith(error: 'User not logged in', actionInProgress: ''));
      return;
    }

    final result = await _attendanceRepo.endBreak(userId: authState.user.id);
    result.fold(
      (f) => emit(state.copyWith(error: f.message, actionInProgress: '')),
      (r) => emit(state.copyWith(todayRecord: r, actionInProgress: '')),
    );
  }

  void clearError() => emit(state.copyWith(error: ''));
}
