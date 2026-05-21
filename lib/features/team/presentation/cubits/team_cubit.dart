import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/domain/repositories/repositories.dart';
import 'package:checkmate/domain/entities/entities.dart';

class TeamState extends Equatable {
  final List<TeamMemberEntity> members;
  final bool isLoading;
  final String? error;

  const TeamState({this.members = const [], this.isLoading = true, this.error});

  TeamState copyWith({
    List<TeamMemberEntity>? members,
    bool? isLoading,
    String? error,
  }) => TeamState(
    members: members ?? this.members,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );

  @override
  List<Object?> get props => [members, isLoading];
}

class TeamCubit extends Cubit<TeamState> {
  final TeamRepository _repo;

  TeamCubit(this._repo) : super(const TeamState()) {
    load();
  }

  Future<void> load() async {
    emit(const TeamState(isLoading: true));
    final result = await _repo.getTeam();
    result.fold(
      (f) => emit(TeamState(isLoading: false, error: f.message)),
      (m) => emit(TeamState(members: m, isLoading: false)),
    );
  }
}
