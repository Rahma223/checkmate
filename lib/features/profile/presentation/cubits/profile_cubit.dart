import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

class ProfileState extends Equatable {
  final List<LeaveEntity> leaves;
  final MonthlyStatsEntity? monthlyStats;
  final bool isLoading;
  final bool isStatsLoading;
  final bool isSubmitting;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.leaves = const [],
    this.monthlyStats,
    this.isLoading = true,
    this.isStatsLoading = false,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    List<LeaveEntity>? leaves,
    MonthlyStatsEntity? monthlyStats,
    bool? isLoading,
    bool? isStatsLoading,
    bool? isSubmitting,
    String? error,
    String? successMessage,
  }) => ProfileState(
    leaves: leaves ?? this.leaves,
    monthlyStats: monthlyStats ?? this.monthlyStats,
    isLoading: isLoading ?? this.isLoading,
    isStatsLoading: isStatsLoading ?? this.isStatsLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    error: error,
    successMessage: successMessage,
  );

  @override
  List<Object?> get props => [
    leaves,
    monthlyStats,
    isLoading,
    isStatsLoading,
    isSubmitting,
    error,
    successMessage,
  ];
}

class ProfileCubit extends Cubit<ProfileState> {
  final LeaveRepository _leaveRepo;
  final AttendanceRepository _attendanceRepo;
  final AuthCubit _authCubit;
  late final StreamSubscription _authSubscription;

  ProfileCubit(this._leaveRepo, this._attendanceRepo, this._authCubit)
    : super(const ProfileState()) {
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        loadProfileData();
      } else if (authState is AuthUnauthenticated) {
        emit(
          state.copyWith(leaves: [], isLoading: false, isStatsLoading: false),
        );
      }
    });

    if (_authCubit.state is AuthAuthenticated) {
      loadProfileData();
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  Future<void> loadLeaves() async {
    await loadUserLeaves();
  }

  Future<void> loadProfileData() async {
    await Future.wait([loadUserLeaves(), loadMonthlyStats()]);
  }

  Future<void> loadUserLeaves() async {
    final authState = _authCubit.state;

    if (authState is! AuthAuthenticated) {
      emit(state.copyWith(isLoading: false, error: 'User not logged in'));
      return;
    }

    emit(state.copyWith(isLoading: true));
    final result = await _leaveRepo.getUserLeaves(authState.user.id);
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (l) => emit(state.copyWith(leaves: l, isLoading: false)),
    );
  }

  Future<void> loadMonthlyStats({DateTime? month}) async {
    final authState = _authCubit.state;

    if (authState is! AuthAuthenticated) {
      emit(state.copyWith(isStatsLoading: false, error: 'User not logged in'));
      return;
    }

    emit(state.copyWith(isStatsLoading: true));
    final result = await _attendanceRepo.getMonthlyStats(
      month ?? DateTime.now(),
      userId: authState.user.id,
    );
    result.fold(
      (f) => emit(state.copyWith(isStatsLoading: false, error: f.message)),
      (stats) =>
          emit(state.copyWith(monthlyStats: stats, isStatsLoading: false)),
    );
  }

  Future<void> submitLeave({
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    final authState = _authCubit.state;

    if (authState is! AuthAuthenticated) {
      emit(state.copyWith(error: 'User not logged in'));
      return;
    }

    emit(state.copyWith(isSubmitting: true));
    final result = await _leaveRepo.submitLeave(
      userId: authState.user.id,
      type: type,
      fromDate: fromDate,
      toDate: toDate,
      reason: reason,
    );
    await result.fold(
      (f) async => emit(state.copyWith(isSubmitting: false, error: f.message)),
      (_) async {
        await loadUserLeaves();
        emit(
          state.copyWith(
            isSubmitting: false,
            successMessage: 'Leave request submitted',
          ),
        );
      },
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
