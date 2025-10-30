import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // For iOS Simulator:
  // final String _baseUrl = "http://127.0.0.1:8000/proxy";
  // For Android Emulator:
  final String _baseUrl = "http://10.0.2.2:8000/proxy";

  final _headers = {'Content-Type': 'application/json'};

  static const MethodChannel _channel = MethodChannel('secure_api_key');

  static Future<String> getApiKey() async {
    try {
      final String? apiKey = await _channel.invokeMethod('getApiKey');
      return apiKey ?? "";
    } on PlatformException catch (e) {
      print("Failed to get API Key: ${e.message}");
      return "";
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$path'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        throw Exception(
          'API Error: ${responseBody['detail'] ?? response.body}',
        );
      }
    } catch (e) {
      // Catch network errors
      throw Exception('Network Error: $e');
    }
  }

  // Helper for GET requests
  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$path'),
        headers: _headers,
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'API Error: ${responseBody['detail'] ?? response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<Map<String, dynamic>> parseSymptom(
    String text,
    int age,
    String sex,
  ) async {
    return _post('parse', {
      'text': text,
      'age': {'value': age},
      'sex': sex,
      'include_tokens': true,
    });
  }

  Future<Map<String, dynamic>> getDiagnosis(
    List<Map<String, dynamic>> evidence,
    int age,
    String sex,
  ) async {
    return _post('diagnosis', {
      'evidence': evidence,
      'age': {'value': age},
      'sex': sex,
      'extras': {
        // We can add any additional parameters here
      },
    });
  }

  Future<Map<String, dynamic>> getTriage(
    List<Map<String, dynamic>> evidence,
    int age,
    String sex,
  ) async {
    return _post('triage', {
      'evidence': evidence,
      'age': {'value': age},
      'sex': sex,
      'extras': {
        // We can add additional params here if needed
      },
    });
  }
}
