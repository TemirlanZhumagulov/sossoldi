import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'authentication_service.dart';

class ApiService {
  final String baseUrl = 'http://192.168.26.215:8081'; // Change IP accordingly


  Future<File> downloadFile(String filename) async {
    String? token = await AuthenticationService().getToken();  // Assuming you use token-based authentication
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    final response = await http.post(
      Uri.parse('$baseUrl/card/generate-report'),
      headers: {
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode == 200) {
      Directory? directory = (await getExternalStorageDirectory()); // Get external storage directory
      File file = File('${directory!.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Failed to download file');
    }
  }

  Future<dynamic> fetchData(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<String> sendChatMessage(String message) async {
    String? token = await AuthenticationService().getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/v1/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(message),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['response'];
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  Future<String> linkCard(Map<String, String> cardDetails) async {
    String? token = await AuthenticationService().getToken();  // Assuming you use token-based authentication

    final response = await http.post(
      Uri.parse('$baseUrl/card/link-card'), // Update endpoint if necessary
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include this line if your endpoint requires authentication
      },
      body: json.encode(cardDetails),
    );

    if (response.statusCode == 200) {
      return 'Card linked successfully';  // You might want to return a more dynamic response based on the backend
    } else {
      // Here we simply throw an exception if anything goes wrong
      throw Exception('Failed to link card: ${response.body}');
    }
  }


}
