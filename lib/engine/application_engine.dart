import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class ApplicationEngine {
  // GET /api/applications/stats
  static Future<Response> getStats() async {
    return await api.get('/api/applications/stats');
  }

  // GET /api/applications/list
  static Future<Response> getList() async {
    return await api.get('/api/applications/list');
  }

  // POST /api/applications/add
  static Future<Response> addApplication(Map<String, dynamic> payload) async {
    return await api.post('/api/applications/add', data: payload);
  }

  // PUT /api/applications/update
  static Future<Response> updateApplication(Map<String, dynamic> payload) async {
    return await api.put('/api/applications/update', data: payload);
  }

  // DELETE /api/applications/delete
  static Future<Response> deleteApplication(String id) async {
    return await api.delete('/api/applications/delete', data: {
      'id': id,
    });
  }
}