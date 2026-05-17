import 'package:checkmate/data/services/auth_local_data_source.dart';
import 'package:checkmate/data/services/auth_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
  );

  // ─────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // ⚠️ IMPORTANT:
      // remoteDataSource.login MUST return token + user
      await localDataSource.saveToken(result.token);

      return Right(result.user);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.message ?? 'Login failed',
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // PROFILE
  // ─────────────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    final token = await localDataSource.getToken();

    if (token == null || token.isEmpty) {
      return Left(AuthFailure('No token found'));
    }

    try {
      final user = await remoteDataSource.getProfile(token);
      return Right(user);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.message ?? 'Failed to get profile',
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearToken();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Logout failed'));
    }
  }

  // ─────────────────────────────────────────────
  // CHECK LOGIN STATE
  // ─────────────────────────────────────────────
  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }

  // ─────────────────────────────────────────────
  // UPDATE PROFILE
  // ─────────────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> updateProfile(
    UserEntity user,
  ) async {
    try {
      final updatedUser = await remoteDataSource.updateProfile(user);
      return Right(updatedUser);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.message ?? 'Update failed',
        ),
      );
    }
  }
}