import 'package:dio/dio.dart';

import '../config/app_environment.dart';

class ApiClient {
  ApiClient(this.environment, {String? token})
    : dio = Dio(
        BaseOptions(
          baseUrl: environment.apiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
          headers: token == null ? null : {'Authorization': 'Bearer $token'},
        ),
      );

  final AppEnvironment environment;
  final Dio dio;
}
