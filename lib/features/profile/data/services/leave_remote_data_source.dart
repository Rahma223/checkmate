import 'package:checkmate/features/profile/data/models/leave_model.dart';
import 'package:checkmate/features/profile/domain/entities/leave_entity.dart';
import 'package:dio/dio.dart';

class LeaveRemoteDataSource {
  final Dio dio;

  LeaveRemoteDataSource(this.dio);

  Future<void> createLeave(LeaveEntity leave) async {
    await _postLeave(leave);
  }

  Future<LeaveEntity> createLeaveAndReturn(LeaveEntity leave) async {
    final data = await _postLeave(leave);

    return LeaveModel.fromJson(data);
  }

  Future<List<LeaveEntity>> getUserLeaves(String userId) async {
    final response = await dio.get(
      '/items/leave_requests',
      queryParameters: {'filter[user][_eq]': userId, 'sort': '-created_at'},
    );

    final data = response.data['data'] as List<dynamic>? ?? [];

    return data
        .map((item) => LeaveModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> cancelLeave(String leaveId) async {
    await dio.delete('/items/leave_requests/$leaveId');
  }

  Future<Map<String, dynamic>> _postLeave(LeaveEntity leave) async {
    final data = LeaveModel.fromEntity(leave).toJson()
      ..['status'] = 'pending'
      ..remove('approver_name')
      ..remove('approver_note');
    final response = await dio.post('/items/leave_requests', data: data);

    return Map<String, dynamic>.from(response.data['data']);
  }
}
