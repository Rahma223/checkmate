import 'dart:async';

import 'package:checkmate/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:checkmate/features/home/presentation/cubits/home_cubit.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryState extends Equatable {
  final List<AttendanceEntity> records;
  final MonthlyStatsEntity? stats;
  final bool isLoading;
  final String filterStatus;
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
  List<Object?> get props => [records, stats, isLoading, filterStatus, error];
}

class HistoryCubit extends Cubit<HistoryState> {
  final AttendanceRepository _repo;
  final AuthCubit _authCubit;
  final HomeCubit _homeCubit;
  StreamSubscription<HomeState>? _homeSubscription;
  String _lastHomeStatus = '';
  StreamSubscription<AuthState>? _authSubscription;

  HistoryCubit(this._repo, this._authCubit, this._homeCubit)
    : super(const HistoryState()) {
    _authSubscription = _authCubit.stream.listen((state) {
      if (state is AuthAuthenticated) {
        load();
      } else if (state is AuthUnauthenticated) {
        emit(const HistoryState());
      }
    });

    _lastHomeStatus = _homeCubit.state.status;
    _homeSubscription = _homeCubit.stream.listen(_onHomeStateChanged);

    if (_authCubit.currentUser != null) {
      load();
    }
  }

  void _onHomeStateChanged(HomeState state) {
    final currentStatus = state.status;
    if (currentStatus == 'checked_out' && _lastHomeStatus != 'checked_out') {
      load();
    }
    _lastHomeStatus = currentStatus;
  }

  Future<void> load() async {
    final userId = _authCubit.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Unable to load history without a valid user.',
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));
    final results = await Future.wait([
      _repo.getHistory(userId: userId, status: state.filterStatus),
      _repo.getMonthlyStats(DateTime.now(), userId: userId),
    ]);

    final records = (results[0] as dynamic).fold(
      (_) => <AttendanceEntity>[],
      (r) => r,
    );
    final stats = (results[1] as dynamic).fold((_) => null, (r) => r);
    emit(
      state.copyWith(
        records: records,
        stats: stats,
        isLoading: false,
        error: null,
      ),
    );
  }

  void setFilter(String status) {
    emit(state.copyWith(filterStatus: status));
    load();
  }

  @override
  Future<void> close() {
    _homeSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
