import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

class TaskState extends Equatable {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final String filter;
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
