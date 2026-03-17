import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/cache/auth_cache.dart';

class AuthEngine {
  // Matches your Go endpoint: POST /api/auth/register
  static Future<Response> register(String username, String email, String password) async {
    return await api.post('/api/auth/register', data: {
      'username': username,
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

    if (response.statusCode == 200 && response.data['token'] != null) {
      await AuthCache.saveToken(response.data['token']);
    }
    return response;
  }

  // --- NEW METHODS ---

  static Future<Response> verifyEmail(String email, String code) async {
    return await api.post('/api/auth/verify-email', data: {
      'email': email,
      'code': code,
    });
  }

  static Future<Response> resendVerification(String email) async {
    return await api.post('/api/auth/resend-verification', data: {
      'email': email,
    });
  }

  static Future<Response> forgotPassword(String email) async {
    return await api.post('/api/auth/forgot-password', data: {
      'email': email,
    });
  }

  static Future<Response> resetPassword(String token, String newPassword) async {
    return await api.post('/api/auth/reset-password', data: {
      'token': token,
      'new_password': newPassword,
    });
  }

  static Future<Response> updatePassword(String currentPassword, String newPassword) async {
    try {
      // Changed from '/auth/update-password' to include the full path
      return await api.put(
        '/api/auth/update-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}

