import 'package:dio/dio.dart';

class AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSource(this.dio);

  // =========================
  // CHECK IN
  // =========================
  Future<Map<String, dynamic>> checkIn({
    required String userId,
    required double lat,
    required double lng,
    required String location,
  }) async {
    final response = await dio.post(
      '/items/attendance',
      data: {
        "user": userId,
        "check_in": DateTime.now().toIso8601String(),
        "status": "checked_in",
        "location": location,
        "lat": lat,
        "lng": lng,
      },
    );

    return response.data['data'];
  }

  // =========================
  // CHECK OUT
  // =========================
  Future<Map<String, dynamic>> checkOut({
    required String attendanceId,
  }) async {
    final response = await dio.patch(
      '/items/attendance/$attendanceId',
      data: {
        "checkout": DateTime.now().toIso8601String(),
        "status": "checked_out",
      },
    );

    return response.data['data'];
  }

  // =========================
  // HISTORY
  // =========================
  Future<List<dynamic>> getHistory({
    required String userId,
    String? status,
  }) async {
    final queryParameters = {
      "filter[user][_eq]": userId,
      "sort": "-check_in",
      "fields": "*,breaks.*",
      if (status != null && status != 'all')
        "filter[status][_eq]": status,
    };

    final response = await dio.get(
      '/items/attendance',
      queryParameters: queryParameters,
    );

    return response.data['data'];
  }

  // =========================
  // TODAY RECORD
  // =========================
  Future<Map<String, dynamic>?> getTodayRecord({
    required String userId,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final response = await dio.get(
      '/items/attendance',
      queryParameters: {
        'filter[user][_eq]': userId,
        'filter[check_in][_gte]': today.toIso8601String(),
        'filter[check_in][_lt]': tomorrow.toIso8601String(),
        'sort': '-check_in',
        'limit': 1,
        'fields': '*,breaks.*',
      },
    );

    final data = response.data['data'] as List<dynamic>?;

    if (data == null || data.isEmpty) return null;

    return data.first as Map<String, dynamic>;
  }

  // =========================
  // BREAKS
  // =========================
  Future<Map<String, dynamic>> startBreak({
    required String attendanceId,
    required String type,
  }) async {
    try {
      final response = await dio.post(
        '/items/breaks',
        data: {
          "attendance": attendanceId,
          "type": type,
          "start_time": DateTime.now().toIso8601String(),
        },
      );

      return response.data['data'];
    } on DioException catch (e) {
      print("BREAK ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> endBreak({
    required String breakId,
  }) async {
    final response = await dio.patch(
      '/items/breaks/$breakId',
      data: {
        "end_time": DateTime.now().toIso8601String(),
      },
    );

    return response.data['data'];
  }

  Future<Map<String, dynamic>?> getActiveBreak({
    required String attendanceId,
  }) async {
    final response = await dio.get(
      '/items/breaks',
      queryParameters: {
        'filter[attendance][_eq]': attendanceId,
        'filter[end_time][_null]': 'true',
        'limit': 1,
      },
    );

    final data = response.data['data'] as List<dynamic>?;

    if (data == null || data.isEmpty) return null;

    return data.first as Map<String, dynamic>;
  }
}