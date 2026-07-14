import 'package:checkmate/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:checkmate/features/schedule/domain/entities/schedule_entity.dart';
import 'package:checkmate/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleEntity> schedules;

  const ScheduleLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _scheduleRepo;
  final AuthCubit _authCubit;

  ScheduleCubit(this._scheduleRepo, this._authCubit)
    : super(const ScheduleInitial());

  Future<void> loadSchedule() async {
    final userId = _authCubit.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      emit(const ScheduleError('Please sign in to view your schedule.'));
      return;
    }

    emit(const ScheduleLoading());

    try {
      final schedules = await _scheduleRepo.getUserSchedule(userId);
      emit(ScheduleLoaded(schedules));
    } catch (e) {
      emit(ScheduleError(_messageFromError(e)));
    }
  }

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
