import 'package:equatable/equatable.dart';

class HistoryEntity extends Equatable {
  final String id;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String status;

  const HistoryEntity({
    required this.id,
    required this.checkIn,
    this.checkOut,
    required this.status,
  });

  @override
  List<Object?> get props => [id, checkIn, checkOut, status];
}
