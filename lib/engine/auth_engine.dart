import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/cache/auth_cache.dart';

class AuthEngine {
  // Matches your Go endpoint: POST /api/auth/register
  static Future<Response> register(String name, String email, String password) async {
    return await api.post('/api/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  // Matches your Go endpoint: POST /api/auth/login
  static Future<Response> login(String email, String password) async {
    final response = await api.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    // If login is successful, save the token
    if (response.statusCode == 200 && response.data['token'] != null) {
      await AuthCache.saveToken(response.data['token']);
    }
    
    return response;
  }
}