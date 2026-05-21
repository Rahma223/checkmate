import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

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
