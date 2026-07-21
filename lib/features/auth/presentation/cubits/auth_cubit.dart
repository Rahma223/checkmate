import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(const AuthInitial());

  Future<void> checkAuth() async {
    emit(const AuthLoading());

    final isIn = await _repo.isLoggedIn();

    if (!isIn) {
      emit(const AuthUnauthenticated());
      return;
    }

    final result = await _repo.getProfile();

    result.fold((_) async {
      await _repo.logout();
      emit(const AuthUnauthenticated());
    }, (u) => emit(AuthAuthenticated(u)));
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    final result = await _repo.login(email: email, password: password);
    result.fold(
      (f) => emit(AuthError(f.message)),
      (u) => emit(AuthAuthenticated(u)),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> updateProfile(UserEntity user) async {
  final result = await _repo.updateProfile(user);
  result.fold(
    (f) => emit(AuthError(f.message)),
    (u) => emit(AuthAuthenticated(u)),
  );
}

Future<void> refreshUser() async {
  if (state is! AuthAuthenticated) return;

  final result = await _repo.getProfile();

  result.fold(
    (f) => emit(AuthError(f.message)),
    (user) => emit(AuthAuthenticated(user)),
  );
}

UserEntity? get currentUser =>
    state is AuthAuthenticated
        ? (state as AuthAuthenticated).user
        : null;

}
