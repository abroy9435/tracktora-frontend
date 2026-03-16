import 'package:dio/dio.dart';
import '../cache/auth_cache.dart';

class ApiClient {
  late Dio dio;
  
  // Replace this with your Hugging Face URL once hosted
  static const String baseUrl = "http://localhost:7860"; 

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    // --- THE INTERCEPTOR ---
    // This automatically pastes the token in every call
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Retrieve token from your cache file
          final token = await AuthCache.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global errors like 401 (Unauthorized) here
          if (e.response?.statusCode == 401) {
            // Logic to logout or refresh token
          }
          return handler.next(e);
        },
      ),
    );
  }
}

// Global instance to use across the app
final api = ApiClient().dio;