import 'package:checkmate/features/auth/data/services/auth_local_data_source.dart';
import 'package:checkmate/features/auth/data/services/auth_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:checkmate/core/errors/failures.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/domain/repositories/repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

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

      await localDataSource.saveToken(result.token);

      return Right(result.user);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Login failed'));
    }
  }

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
      return Left(ServerFailure(e.message ?? 'Failed to get profile'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearToken();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Logout failed'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user) async {
    try {
      final updatedUser = await remoteDataSource.updateProfile(user);
      return Right(updatedUser);
    } on DioException catch (e) {
      final code = e.response?.data['errors']?[0]?['extensions']?['code'];

      if (code == 'TOKEN_EXPIRED') {
        await localDataSource.clearToken();

        return Left(AuthFailure('Session expired'));
      }

      return Left(ServerFailure(e.message ?? 'Failed to get profile'));
    }
  }
}
