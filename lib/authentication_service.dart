import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final String baseUrl = 'http://192.168.89.167:8081/api/v1/auth';  // Adjust the IP accordingly

  Future<bool> authenticate(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        _saveToken(data['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<bool> register(String firstname, String lastname, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'password': password,
          'role': role,
        }),
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        _saveToken(data['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  void _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setBool('isLoggedIn', true);  // Mark the user as logged in
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

}
