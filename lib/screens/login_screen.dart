import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  bool _sifreGorunur = false;
  bool _yukleniyor = false;

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = _emailController.text.trim();
    final sifre = _sifreController.text.trim();

    setState(() => _yukleniyor = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/login"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "sifre": sifre,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Giriş başarılı, kullanıcı id'sini sakla
        final user = data['user'];
ApiService.currentUserId = user['id'];
ApiService.currentUserAdSoyad = user['adSoyad'];
ApiService.currentUserEmail = user['email'];
ApiService.currentUserUniversite = user['universite'];
ApiService.currentUserStudentNo = user['studentNo']?.toString();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Giriş başarısız')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlantı hatası: $e')),
      );
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş Yap"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "E-posta",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen email adresinizi giriniz';
                  }
                  final email = value.trim().toLowerCase();
                  final gecerliUzantilar = [
  '@ogr.gidatarim.edu.tr',
  '@ogr.selcuk.edu.tr',
  '@asu.edu.tr',
  '@ktun.edu.tr',
  '@konya.edu.tr',
];
                  final gecerliMi =
                      gecerliUzantilar.any((uzanti) => email.endsWith(uzanti));
                  if (!gecerliMi) {
                    return 'Sadece öğrenci email adresiyle giriş yapabilirsiniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sifreController,
                obscureText: !_sifreGorunur,
                decoration: InputDecoration(
                  labelText: "Şifre",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _sifreGorunur ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _sifreGorunur = !_sifreGorunur;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _yukleniyor
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await login();
                        }
                      },
                child: _yukleniyor
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Giriş Yap"),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Hesabın yok mu? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text("Kayıt Ol"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}