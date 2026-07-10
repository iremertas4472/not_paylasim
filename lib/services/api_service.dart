import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Dersler yüklenemedi (${response.statusCode})');
    }
  }

  static Future<List<Map<String, dynamic>>> getNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/notes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Notlar yüklenemedi (${response.statusCode})');
    }
  }

  static Future<void> createNote({
    required String baslik,
    required String aciklama,
    required String dersAdi,
    required String dosyaAdi,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'baslik': baslik,
        'aciklama': aciklama,
        'dersAdi': dersAdi,
        'dosyaAdi': dosyaAdi,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Not eklenemedi (${response.statusCode})');
    }
  }
}