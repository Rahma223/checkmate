import 'package:dio/dio.dart';

abstract class HistoryRemoteDataSource {
  Future<List<dynamic>> getHistory();
}

class HistoryRemoteDataSourceImpl
    implements HistoryRemoteDataSource {

  final Dio dio;

  HistoryRemoteDataSourceImpl(this.dio);

  @override
  Future<List<dynamic>> getHistory() async {

    final response = await dio.get(
      '/items/attendance',
      queryParameters: {
        "sort": "-check_in",
      },
    );

    return response.data['data'];
  }
}