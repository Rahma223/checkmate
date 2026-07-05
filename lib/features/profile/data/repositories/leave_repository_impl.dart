import 'package:checkmate/core/errors/failures.dart';
import 'package:checkmate/features/profile/data/services/leave_remote_data_source.dart';
import 'package:checkmate/features/profile/domain/entities/leave_entity.dart';
import 'package:checkmate/features/profile/domain/repositories/leave_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveRemoteDataSource remoteDataSource;

  LeaveRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> createLeave(LeaveEntity leave) async {
    try {
      await remoteDataSource.createLeave(leave);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e, 'Failed to create leave')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeaveEntity>>> getUserLeaves(
    String userId,
  ) async {
    try {
      final leaves = await remoteDataSource.getUserLeaves(userId);
      return Right(leaves);
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e, 'Failed to load leaves')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LeaveEntity>> submitLeave({
    required String userId,
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    try {
      final leave = LeaveEntity(
        id: '',
        userId: userId,
        type: type,
        fromDate: fromDate,
        toDate: toDate,
        reason: reason,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final createdLeave = await remoteDataSource.createLeaveAndReturn(leave);
      return Right(createdLeave);
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e, 'Failed to submit leave')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelLeave(String leaveId) async {
    try {
      await remoteDataSource.cancelLeave(leaveId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e, 'Failed to cancel leave')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _messageFromDio(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final errors = data['errors'];

      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;

        if (first is Map<String, dynamic> && first['message'] != null) {
          return first['message'].toString();
        }
      }
    }

    return e.message ?? fallback;
  }
}
