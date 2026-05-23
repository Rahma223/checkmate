import '../../domain/entities/history_entity.dart';

class HistoryModel extends HistoryEntity {

  const HistoryModel({
    required super.id,
    required super.checkIn,
    super.checkOut,
    required super.status,
  });

  factory HistoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return HistoryModel(
      id: json['id'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: json['checkout'] != null
          ? DateTime.parse(json['checkout'])
          : null,
      status: json['status'] ?? '',
    );
  }
}