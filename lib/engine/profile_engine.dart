import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class ProfileEngine {
  // GET /api/profile
  static Future<Response> getProfile() async {
    return await api.get('/api/profile');
  }

  // PUT /api/profile/update
  static Future<Response> updateProfile(String username) async {
    return await api.put('/api/profile/update', data: {
      'username': username,
    });
  }

  // PUT /api/profile/privacy
  static Future<Response> updatePrivacy(bool shareStats) async {
    return await api.put('/api/profile/privacy', data: {
      'share_stats': shareStats, 
    });
  }
}