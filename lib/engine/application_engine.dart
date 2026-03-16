import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class ApplicationEngine {
  // GET /api/applications/stats
  static Future<Response> getStats() async {
    return await api.get('/api/applications/stats'); // Added /api
  }

  // GET /api/applications/list
  static Future<Response> getList() async {
    return await api.get('/api/applications/list'); // Added /api
  }
}