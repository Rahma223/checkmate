import 'package:equatable/equatable.dart';

class TeamMemberEntity extends Equatable {
  final String id;
  final String name;
  final String position;
  final String department;
  final String avatarUrl;
  final String status;
  final String? checkInTime;
  final String? workLocation;

  const TeamMemberEntity({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    this.avatarUrl = '',
    required this.status,
    this.checkInTime,
    this.workLocation,
  });

  String get initials =>
      name.split(' ').take(2).map((n) => n[0]).join().toUpperCase();

  @override
  List<Object?> get props => [id, name, status];
}
