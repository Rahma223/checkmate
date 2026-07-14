import 'package:checkmate/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:checkmate/features/profile/domain/entities/leave_entity.dart';
import 'package:checkmate/features/profile/domain/repositories/leave_repository.dart';
import 'package:checkmate/features/schedule/domain/entities/schedule_entity.dart';
import 'package:checkmate/features/schedule/domain/entities/shift_entity.dart';
import 'package:checkmate/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ScheduleState extends Equatable {
  final DateTime selectedMonth;
  final DateTime selectedDay;
  final List<ScheduleEntity> schedules;
  final List<ShiftEntity> shifts;
  final List<LeaveEntity> leaves;
  final bool isLoading;
  final String? error;

  const ScheduleState({
    required this.selectedMonth,
    required this.selectedDay,
    this.schedules = const [],
    this.shifts = const [],
    this.leaves = const [],
    this.isLoading = false,
    this.error,
  });

  factory ScheduleState.initial() {
    final now = DateTime.now();
    return ScheduleState(
      selectedMonth: DateTime(now.year, now.month),
      selectedDay: DateTime(now.year, now.month, now.day),
    );
  }

  List<ShiftEntity> get selectedDayShifts =>
      shifts.where((shift) => _isSameDay(shift.date, selectedDay)).toList();

  bool hasShift(DateTime day) =>
      shifts.any((shift) => _isSameDay(shift.date, day));

  bool hasLeave(DateTime day) => leaves.any(
    (leave) =>
        !_dateOnly(day).isBefore(_dateOnly(leave.fromDate)) &&
        !_dateOnly(day).isAfter(_dateOnly(leave.toDate)),
  );

  ScheduleState copyWith({
    DateTime? selectedMonth,
    DateTime? selectedDay,
    List<ScheduleEntity>? schedules,
    List<ShiftEntity>? shifts,
    List<LeaveEntity>? leaves,
    bool? isLoading,
    String? error,
  }) => ScheduleState(
    selectedMonth: selectedMonth ?? this.selectedMonth,
    selectedDay: selectedDay ?? this.selectedDay,
    schedules: schedules ?? this.schedules,
    shifts: shifts ?? this.shifts,
    leaves: leaves ?? this.leaves,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  List<Object?> get props => [
    selectedMonth,
    selectedDay,
    schedules,
    shifts,
    leaves,
    isLoading,
    error,
  ];
}

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _scheduleRepo;
  final LeaveRepository _leaveRepo;
  final AuthCubit _authCubit;

  ScheduleCubit(this._scheduleRepo, this._leaveRepo, this._authCubit)
    : super(ScheduleState.initial());

  Future<void> loadMonth(DateTime month) async {
    final userId = _authCubit.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Please sign in to view your schedule.',
        ),
      );
      return;
    }

    final selectedMonth = DateTime(month.year, month.month);
    final selectedDay =
        state.selectedDay.year == selectedMonth.year &&
            state.selectedDay.month == selectedMonth.month
        ? state.selectedDay
        : DateTime(selectedMonth.year, selectedMonth.month, 1);

    emit(
      state.copyWith(
        selectedMonth: selectedMonth,
        selectedDay: selectedDay,
        isLoading: true,
      ),
    );

    try {
      final schedules = await _scheduleRepo.getUserSchedule(userId);
      final leavesResult = await _leaveRepo.getUserLeaves(userId);

      leavesResult.fold(
        (failure) =>
            emit(state.copyWith(isLoading: false, error: failure.message)),
        (leaves) => emit(
          state.copyWith(
            schedules: schedules,
            shifts: schedules
                .where((s) => s.isWorkingDay)
                .map(_toShift)
                .toList(),
            leaves: leaves,
            isLoading: false,
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: _messageFromError(e)));
    }
  }

  Future<void> loadSchedule() => loadMonth(state.selectedMonth);

  void selectDay(DateTime day) {
    emit(state.copyWith(selectedDay: day));
  }

  ShiftEntity _toShift(ScheduleEntity schedule) => ShiftEntity(
    id: schedule.id,
    date: schedule.workDate,
    startTime: DateFormat('hh:mm a').format(schedule.shiftStart),
    endTime: DateFormat('hh:mm a').format(schedule.shiftEnd),
    location: schedule.workLocation.isEmpty
        ? 'No location assigned'
        : schedule.workLocation,
    type: 'regular',
    notes: schedule.day.isEmpty ? null : schedule.day,
  );

  String _messageFromError(Object error) {
    final message = error.toString();
    if (message.startsWith('ApiException')) {
      final index = message.indexOf(': ');
      if (index != -1 && index + 2 < message.length) {
        return message.substring(index + 2);
      }
    }

    return message.isEmpty ? 'Failed to load schedule.' : message;
  }
}
