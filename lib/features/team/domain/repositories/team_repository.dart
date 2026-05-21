import 'package:dartz/dartz.dart';
import 'package:checkmate/core/errors/failures.dart';
import '../entities/team_member_entity.dart';

abstract class TeamRepository {
  Future<Either<Failure, List<TeamMemberEntity>>> getTeam();
}
