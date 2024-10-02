import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class NetworkService {
  final String baseUrl;
  final http.Client client;

  NetworkService({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$path');

    try {
     
      final response = await client.get(url, headers: headers).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$path');

    try {
      final response = await client.post(
        url,
        headers: headers ?? {"Content-Type": "application/json"},
        body: jsonEncode(body ?? {}),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  void close() {
    client.close();
  }
}