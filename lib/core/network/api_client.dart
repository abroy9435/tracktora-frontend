import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../cache/auth_cache.dart';

class ApiClient {
  late Dio dio;

  // Pulls from .env file, defaults to local if the key is missing
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? "http://localhost:7860";

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15), // Increased for cloud wake-up
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // --- THE INTERCEPTOR ---
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Automatically inject the JWT token if it exists
          final token = await AuthCache.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Global session handling: clear cache if token is invalid/expired
          if (e.response?.statusCode == 401) {
            AuthCache.clear();
            // You could also trigger a navigation to /login here if needed
          }
          return handler.next(e);
        },
      ),
    );
  }
}

// Global instance to use across the app
final api = ApiClient().dio;