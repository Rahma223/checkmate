import 'package:dio/dio.dart';

class AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSource(this.dio);

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
  Future<Map<String, dynamic>> checkOut({
    required int attendanceId,
  }) async {
    final response = await dio.patch(
      '/items/attendance/$attendanceId',
      data: {
        'check_out': DateTime.now().toIso8601String(),
        'status': 'checked_out',
      },
    );

    return response.data['data'];
  }

  Future<List<dynamic>> getAttendance() async {

    final response = await dio.get(
      '/items/attendance',
    );

    return response.data['data'];
  }
}