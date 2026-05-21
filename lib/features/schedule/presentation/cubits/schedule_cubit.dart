import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

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
