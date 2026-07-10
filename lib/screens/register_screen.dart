import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form alarını kontrol etmek için controller tanımlamaları
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _studentNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _sifreTekrarController = TextEditingController();

  bool _sifreGorunur = false;
  bool _sifreTekrarGorunur = false;

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _studentNoController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    _sifreTekrarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Ad Alanı
                TextFormField(
                  controller: _adController,
                  decoration: const InputDecoration(
                    labelText: 'Ad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen adınızı giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Soyad Alanı
                TextFormField(
                  controller: _soyadController,
                  decoration: const InputDecoration(
                    labelText: 'Soyad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen soyadınızı giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Öğrenci Numarası Alanı
                TextFormField(
                  controller: _studentNoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Öğrenci Numarası',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen öğrenci numaranızı giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // E-posta Alanı
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
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
                    ];
                    final gecerliMi =
                        gecerliUzantilar.any((uzanti) => email.endsWith(uzanti));
                    if (!gecerliMi) {
                      return 'Sadece öğrenci email adresiyle kayıt olabilirsiniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Şifre Alanı
                TextFormField(
                  controller: _sifreController,
                  obscureText: !_sifreGorunur,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
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
                      return 'Lütfen bir şifre belirleyiniz';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Şifre Tekrar Alanı
                TextFormField(
                  controller: _sifreTekrarController,
                  obscureText: !_sifreTekrarGorunur,
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _sifreTekrarGorunur
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _sifreTekrarGorunur = !_sifreTekrarGorunur;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi tekrar giriniz';
                    }
                    if (value.trim() != _sifreController.text.trim()) {
                      return 'Şifreler eşleşmiyor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Kayıt Ol Butonu
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form doğrulaması başarılıysa burası çalışacak
                      // İlerleyen aşamalarda backend API isteğimizi buraya bağlayacağız.

                      String tamAdSoyad =
                          "${_adController.text} ${_soyadController.text}";

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Kayıt alınıyor: $tamAdSoyad')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      const Text('Kayıt Ol', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}