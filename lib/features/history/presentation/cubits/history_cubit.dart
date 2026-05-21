import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

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
