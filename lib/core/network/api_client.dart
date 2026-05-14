import 'package:dio/dio.dart';

/// Stub API client.
/// Replace [baseUrl] with your real endpoint and add interceptors (auth token, etc.).
class ApiClient {
  ApiClient._();

  static const String baseUrl = 'https://api.workforcecentral.com/v1';

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // TODO: add your interceptors here
    // dio.interceptors.add(AuthInterceptor());
    // dio.interceptors.add(LogInterceptor());

    return dio;
  }
}

/// Placeholder exception – replace with your actual API error model.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
