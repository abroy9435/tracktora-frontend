import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class ConnectEngine {
  static Future<Response> searchUsers(String query) async {
    return await api.get('/api/connect/search', queryParameters: {'q': query});
  }

  static Future<Response> sendInvite(String friendId) async {
    return await api.post('/api/connect/invite', data: {'friend_id': friendId});
  }

  // --- NEW: Cancel an invite you just sent ---
  static Future<Response> cancelInvite(String friendId) async {
    return await api.post('/api/connect/cancel', data: {'friend_id': friendId});
  }

  static Future<Response> getPendingRequests() async {
    return await api.get('/api/connect/requests');
  }

  static Future<Response> respondToRequest(String senderId, String status) async {
    return await api.put('/api/connect/respond', data: {
      'friend_id': senderId,
      'status': status,
    });
  }

  static Future<Response> getFriendList() async {
    return await api.get('/api/connect/list');
  }

  static Future<Response> getFriendStats(String friendId) async {
    return await api.get('/api/connect/stats/$friendId');
  }
}