import 'package:dartz/dartz.dart';
import 'package:checkmate/core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user);
  Future<bool> isLoggedIn();
}
