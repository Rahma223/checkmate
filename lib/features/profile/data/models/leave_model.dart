import 'package:checkmate/features/profile/domain/entities/leave_entity.dart';

class LeaveModel extends LeaveEntity {
  const LeaveModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.fromDate,
    required super.toDate,
    required super.reason,
    required super.status,
    super.approverName,
    super.approverNote,
    required super.createdAt,
  });

  factory LeaveModel.fromEntity(LeaveEntity leave) => LeaveModel(
    id: leave.id,
    userId: leave.userId,
    type: leave.type,
    fromDate: leave.fromDate,
    toDate: leave.toDate,
    reason: leave.reason,
    status: leave.status,
    approverName: leave.approverName,
    approverNote: leave.approverNote,
    createdAt: leave.createdAt,
  );

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return LeaveModel(
      id: json['id']?.toString() ?? '',
      userId: user is Map<String, dynamic>
          ? user['id']?.toString() ?? ''
          : user?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      fromDate: DateTime.parse(json['from_date']),
      toDate: DateTime.parse(json['to_date']),
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      approverName: json['approver_name']?.toString(),
      approverNote: json['approver_note']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user': userId,
      'type': type,
      'from_date': _formatDate(fromDate),
      'to_date': _formatDate(toDate),
      'reason': reason,
      'status': status,
      if (approverName != null) 'approver_name': approverName,
      if (approverNote != null) 'approver_note': approverNote,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}
