import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.200.249:3000';
  static int? currentUserId;
  static String? currentUserAdSoyad;
  static String? currentUserEmail;
  static String? currentUserUniversite;
  static String? currentUserStudentNo;

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
    required File dosya,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/notes'));
    request.fields['baslik'] = baslik;
    request.fields['aciklama'] = aciklama;
    request.fields['dersAdi'] = dersAdi;
    request.fields['userId'] = currentUserId.toString();
    request.files.add(await http.MultipartFile.fromPath('dosya', dosya.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception('Not eklenemedi (${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String adSoyad,
    required String studentNo,
    required String email,
    required String sifre,
    required String universite,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'adSoyad': adSoyad,
        'studentNo': studentNo,
        'email': email,
        'sifre': sifre,
        'universite': universite,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? 'Kayit basarisiz');
    }

    return data;
  }

  static Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String kod,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'kod': kod,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Dogrulama basarisiz');
    }

    return data;
  }
}