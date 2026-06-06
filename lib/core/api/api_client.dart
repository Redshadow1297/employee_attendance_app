import 'package:dio/dio.dart';
import 'api_constants.dart';

class ApiClient {
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            request: true,
            requestHeader: true,
            requestBody: true,
            responseHeader: false,
            responseBody: true,
            error: true,
          ),
        );

  /// ========================= GET =========================
  static Future<Response> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// ========================= POST =========================
  static Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// ========================= PUT =========================
  static Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// ========================= DELETE =========================
  static Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// ========================= ERROR HANDLER =========================
  static String _handleError(DioException e) {
    // Server responded with error
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return data["message"] ?? data["error"] ?? "Server error occurred";
      }

      return "Server error occurred";
    }

    // Timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return "Connection timeout. Please try again.";
    }

    // No internet
    if (e.type == DioExceptionType.connectionError) {
      return "No internet connection.";
    }

    return "Unexpected error occurred.";
  }

  /// ========================= TOKEN SETTER =========================
  static void setAuthToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  /// ========================= CLEAR TOKEN =========================
  static void clearAuthToken() {
    _dio.options.headers.remove("Authorization");
  }
}
