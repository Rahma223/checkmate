import 'package:equatable/equatable.dart';

class ShiftEntity extends Equatable {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final String type;
  final String? notes;

  const ShiftEntity({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    this.notes,
  });

  @override
  List<Object?> get props => [id, date, type];
}
