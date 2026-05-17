import 'package:dio/dio.dart';

/// Stub API client.
/// Replace [baseUrl] with your real endpoint and add interceptors (auth token, etc.).


class ApiClient {
  ApiClient._();

  static const String baseUrl =
      'https://checkmate-directus.csiwm3.easypanel.host';

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

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

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
