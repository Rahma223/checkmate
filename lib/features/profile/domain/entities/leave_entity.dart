import 'package:equatable/equatable.dart';

class LeaveEntity extends Equatable {
  final String id;
  final String userId;
  final String type;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status;
  final String? approverName;
  final String? approverNote;
  final DateTime createdAt;

  const LeaveEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    this.approverName,
    this.approverNote,
    required this.createdAt,
  });

  int get daysCount => toDate.difference(fromDate).inDays + 1;

  @override
  List<Object?> get props => [id, userId, type, fromDate, toDate, status];
}
