import 'package:checkmate/features/auth/data/repositories/auth_response.dart';
import 'package:dio/dio.dart';
import 'package:checkmate/domain/entities/entities.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    // LOGIN
    final loginResponse = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},

      // ignore: avoid_print
    );
    print("==========${loginResponse.data}");
    final token = loginResponse.data['data']['access_token'];

    // ADD TOKEN
    dio.options.headers['Authorization'] = 'Bearer $token';

    // GET CURRENT USER
    final userResponse = await dio.get('/users/me');

    final data = userResponse.data['data'];

    final user = UserEntity(
      id: data['id'],
      name: '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      position: data['position'] ?? '',
      employeeId: data['employee_id'] ?? '',
      avatarUrl: '',
      phone: data['phone'] ?? '',
      shiftStart: data['shift_start'] ?? '09:00',
      shiftEnd: data['shift_end'] ?? '17:30',
      workLocation: data['work_location'] ?? '',
      totalLeaves: data['total_leaves'] ?? 21,
      usedLeaves: data['used_leaves'] ?? 0,
    );

    return AuthResponse(user: user, token: token);
  }

  Future<UserEntity> getProfile(String token) async {
    dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await dio.get('/users/me');

    final data = response.data['data'];

    return UserEntity(
      id: data['id'],
      name: '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      position: data['position'] ?? '',
      employeeId: data['employee_id'] ?? '',
      avatarUrl: '',
      phone: data['phone'] ?? '',
      shiftStart: data['shift_start'] ?? '09:00',
      shiftEnd: data['shift_end'] ?? '17:30',
      workLocation: data['work_location'] ?? '',
      totalLeaves: data['total_leaves'] ?? 21,
      usedLeaves: data['used_leaves'] ?? 0,
    );
  }

  Future<Map<String, dynamic>> checkOut({required int attendanceId}) async {
    final response = await dio.patch(
      '/items/attendance/$attendanceId',
      data: {
        'check_out': DateTime.now().toIso8601String(),
        'status': 'checked_out',
      },
    );

    return response.data['data'];
  }

  Future<UserEntity> updateProfile(UserEntity user) async {
    final response = await dio.patch(
      '/users/me',
      data: {
        'first_name': user.name.split(' ').first,
        'last_name': user.name.split(' ').skip(1).join(' '),
        'phone': user.phone,
        'department': user.department,
        'position': user.position,
      },
    );

    final data = response.data['data'];

    return UserEntity(
      id: data['id'],
      name: '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      position: data['position'] ?? '',
      employeeId: data['employee_id'] ?? '',
      avatarUrl: '',
      phone: data['phone'] ?? '',
      shiftStart: data['shift_start'] ?? '09:00',
      shiftEnd: data['shift_end'] ?? '17:30',
      workLocation: data['work_location'] ?? '',
      totalLeaves: data['total_leaves'] ?? 21,
      usedLeaves: data['used_leaves'] ?? 0,
    );
  }
}
