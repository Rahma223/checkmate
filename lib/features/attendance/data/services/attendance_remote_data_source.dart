import 'package:dio/dio.dart';

class AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSource(this.dio);

  // CHECK IN
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

  // CHECK OUT
  Future<Map<String, dynamic>> checkOut({required String attendanceId}) async {
    final response = await dio.patch(
      '/items/attendance/$attendanceId',
     data: {
  "checkout":
      DateTime.now().toIso8601String(),
  "status": "checked_out",
}
    );

    return response.data['data'];
  }

  Future<List<dynamic>> getHistory({
  required String userId,
}) async {

  final response = await dio.get(
    '/items/attendance',
    queryParameters: {
      "filter[user][_eq]": userId,

      
      "sort": "-check_in",
    },
  );

  return response.data['data'];
}

  Future<Map<String, dynamic>> startBreak({
    required String attendanceId,
    required String type,
  }) async {
    final response = await dio.post(
      '/items/attendance_breaks',
      data: {
        "attendance": attendanceId,
        "type": type,
        "start_time": DateTime.now().toIso8601String(),
      },
    );

    return response.data['data'];
  }

  Future<Map<String, dynamic>> endBreak({required String breakId}) async {
    final response = await dio.patch(
      '/items/attendance_breaks/$breakId',
      data: {"end_time": DateTime.now().toIso8601String()},
    );

    return response.data['data'];
  }
}
