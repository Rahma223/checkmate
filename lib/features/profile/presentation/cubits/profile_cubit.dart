import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

class ProfileState extends Equatable {
  final List<LeaveEntity> leaves;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.leaves = const [],
    this.isLoading = true,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    List<LeaveEntity>? leaves,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? successMessage,
  }) => ProfileState(
    leaves: leaves ?? this.leaves,
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    error: error,
    successMessage: successMessage,
  );

  @override
  List<Object?> get props => [
    leaves,
    isLoading,
    isSubmitting,
    error,
    successMessage,
  ];
}

class ProfileCubit extends Cubit<ProfileState> {
  final LeaveRepository _leaveRepo;

  ProfileCubit(this._leaveRepo) : super(const ProfileState()) {
    loadLeaves();
  }

  Future<void> loadLeaves() async {
    emit(state.copyWith(isLoading: true));
    final result = await _leaveRepo.getLeaves();
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (l) => emit(state.copyWith(leaves: l, isLoading: false)),
    );
  }

  Future<void> submitLeave({
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    emit(state.copyWith(isSubmitting: true));
    final result = await _leaveRepo.submitLeave(
      type: type,
      fromDate: fromDate,
      toDate: toDate,
      reason: reason,
    );
    result.fold(
      (f) => emit(state.copyWith(isSubmitting: false, error: f.message)),
      (l) => emit(
        state.copyWith(
          isSubmitting: false,
          leaves: [l, ...state.leaves],
          successMessage: 'Leave request submitted',
        ),
      ),
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
