import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class ResumeEngine {
  /// --- GENERIC VAULT HELPERS ---
  /// These allow the Vault UI to be dynamic and reusable.
  
  static Future<Response> getVaultItems(String category) async {
    // category will be 'project', 'experience', 'education', 'skill', or 'certification'
    return await api.get('/api/resume/vault/$category');
  }

  static Future<Response> addToVault(String category, Map<String, dynamic> data) async {
    return await api.post('/api/resume/vault/$category', data: data);
  }

  static Future<Response> updateVaultItem(String category, Map<String, dynamic> data) async {
    return await api.put('/api/resume/vault/$category', data: data);
  }

  static Future<Response> deleteVaultItem(String category, String id) async {
    return await api.delete('/api/resume/vault/$category', data: {'id': id});
  }

  /// --- EXPLICIT VAULT ACTIONS ---
  /// Used by specific forms for better code readability.

  // Projects
  static Future<Response> addProject(Map<String, dynamic> data) => addToVault('project', data);
  static Future<Response> deleteProject(String id) => deleteVaultItem('project', id);

  // Experience
  static Future<Response> addExperience(Map<String, dynamic> data) => addToVault('experience', data);
  static Future<Response> deleteExperience(String id) => deleteVaultItem('experience', id);

  // Education
  static Future<Response> addEducation(Map<String, dynamic> data) => addToVault('education', data);

  // Skills
  static Future<Response> addSkill(Map<String, dynamic> data) => addToVault('skill', data);

  // Certifications
  static Future<Response> addCertification(Map<String, dynamic> data) => addToVault('certification', data);

  /// --- RESUME MANAGEMENT (THE BUILDER) ---
  
  // Saves the blueprint (the array of IDs and summary) to Supabase
  static Future<Response> buildResume(Map<String, dynamic> blueprintData) async {
    return await api.post('/api/resume/build', data: blueprintData);
  }

  // Lists all the "blueprints" the user has saved
  static Future<Response> getSavedResumes() async {
    return await api.get('/api/resume/list');
  }

  // THE MAGIC ENDPOINT: Fetches the full, nested data for a specific resume ID
  static Future<Response> getCompiledResume(String resumeId) async {
    return await api.get('/api/resume/compile/$resumeId');
  }

  // Deletes a specific resume version
  static Future<Response> deleteResume(String resumeId) async {
    return await api.delete('/api/resume/delete/$resumeId');
  }
}