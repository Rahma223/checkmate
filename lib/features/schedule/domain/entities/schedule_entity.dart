import 'package:equatable/equatable.dart';

class ScheduleEntity extends Equatable {
  final String id;
  final String userId;
  final String day;
  final DateTime workDate;
  final DateTime shiftStart;
  final DateTime shiftEnd;
  final String workLocation;
  final bool isWorkingDay;

  const ScheduleEntity({
    required this.id,
    required this.userId,
    required this.day,
    required this.workDate,
    required this.shiftStart,
    required this.shiftEnd,
    required this.workLocation,
    required this.isWorkingDay,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    day,
    workDate,
    shiftStart,
    shiftEnd,
    workLocation,
    isWorkingDay,
  ];
}
