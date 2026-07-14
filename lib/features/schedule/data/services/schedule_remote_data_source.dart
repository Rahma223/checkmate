import 'package:checkmate/core/network/api_client.dart';
import 'package:checkmate/features/schedule/data/models/schedule_model.dart';
import 'package:checkmate/features/schedule/domain/entities/schedule_entity.dart';
import 'package:dio/dio.dart';

class ScheduleRemoteDataSource {
  final Dio dio;

  ScheduleRemoteDataSource(this.dio);

  Future<List<ScheduleEntity>> getUserSchedule(String userId) async {
    try {
      final response = await dio.get(
        '/items/Schedules',
        queryParameters: {
          'filter[user][_eq]': userId,
          'sort': 'work_date',
          'fields': '*,user.id',
        },
      );

      final data = response.data['data'] as List<dynamic>? ?? [];

      return data
          .map(
            (item) =>
                ScheduleModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode ?? 500,
        message: _messageFromDio(e),
      );
    }
  }

  String _messageFromDio(DioException e) {
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

    return e.message ?? 'Failed to load schedule';
  }
}
