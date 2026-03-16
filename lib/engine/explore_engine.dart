import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class ExploreEngine {
  // GET /api/explore
  static Future<Response> getFeed() async {
    return await api.get('/api/explore'); // Added /api
  }

  // POST /api/explore/save
  static Future<Response> saveOpportunity(String companyName, String roleTitle, String jobUrl) async {
    return await api.post('/api/explore/save', data: {
      'company_name': companyName,
      'role_title': roleTitle,
      'job_url': jobUrl,
      'status': 'Wishlist', // Backend defaults to this if empty, but good to be explicit
    });
  }
}