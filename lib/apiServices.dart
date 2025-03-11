import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://neuurelief.onrender.com'; // Replace with actual Render URL

  Future<List<String>> getConditions() async {
    final response = await http.get(Uri.parse('$baseUrl/conditions'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['conditions']);
    } else {
      throw Exception('Failed to load conditions: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, List<String> conditions) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'conditions': conditions,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Signup failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    print('Login response status: ${response.statusCode}');
    print('Login response body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception('Login failed: ${errorData['error']}');
      } catch (e) {
        throw Exception('Login failed: ${response.body}');
      }
    }
  }
}