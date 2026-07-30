import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'verify_code_screen.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
String? _secilenUniversite;

final List<Map<String, String>> _universiteler = [
  {'ad': 'Selçuk Üniversitesi', 'uzanti': '@ogr.selcuk.edu.tr'},
  {'ad': 'Konya Gıda ve Tarım Üniversitesi', 'uzanti': '@ogr.gidatarim.edu.tr'},
  {'ad': 'Aksaray Üniversitesi', 'uzanti': '@asu.edu.tr'},
  {'ad': 'Konya Teknik Üniversitesi', 'uzanti': '@ktun.edu.tr'},
  {'ad': 'Necmettin Erbakan Üniversitesi', 'uzanti': '@konya.edu.tr'},
];
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _studentNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _sifreTekrarController = TextEditingController();

  bool _sifreGorunur = false;
  bool _sifreTekrarGorunur = false;
  bool _yukleniyor = false;

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

Future<void> _kayitOl() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _yukleniyor = true);

  try {
    String tamAdSoyad = "${_adController.text.trim()} ${_soyadController.text.trim()}";

    await ApiService.register(
      adSoyad: tamAdSoyad,
      studentNo: _studentNoController.text.trim(),
      email: _emailController.text.trim(),
      sifre: _sifreController.text.trim(),
      universite: _secilenUniversite ?? '',
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyCodeScreen(email: _emailController.text.trim()),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kayit sirasinda hata olustu: $e'), backgroundColor: Colors.red),
    );
  } finally {
    if (mounted) setState(() => _yukleniyor = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayit Ol'),
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

                TextFormField(
                  controller: _adController,
                  decoration: const InputDecoration(
                    labelText: 'Ad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lutfen adinizi giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _soyadController,
                  decoration: const InputDecoration(
                    labelText: 'Soyad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lutfen soyadinizi giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _studentNoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ogrenci Numarasi',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lutfen ogrenci numaranizi giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
  initialValue: _secilenUniversite,
  decoration: const InputDecoration(
    labelText: 'Üniversite',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.school),
  ),
  items: _universiteler
      .map((uni) => DropdownMenuItem<String>(
            value: uni['ad'],
            child: Text(uni['ad']!),
          ))
      .toList(),
  onChanged: (value) {
    setState(() => _secilenUniversite = value);
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen üniversitenizi seçiniz';
    }
    return null;
  },
),
const SizedBox(height: 16),
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
    return 'Lutfen email adresinizi giriniz';
  }
  if (_secilenUniversite == null) {
    return 'Once universitenizi seciniz';
  }
  final email = value.trim().toLowerCase();
  final secilenUzanti = _universiteler
      .firstWhere((uni) => uni['ad'] == _secilenUniversite)['uzanti']!;
  if (!email.endsWith(secilenUzanti)) {
    return 'Email adresiniz secilen universiteyle eslesmiyor ($secilenUzanti)';
  }
  return null;
},
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _sifreController,
                  obscureText: !_sifreGorunur,
                  decoration: InputDecoration(
                    labelText: 'Sifre',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_sifreGorunur ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _sifreGorunur = !_sifreGorunur),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lutfen bir sifre belirleyiniz';
                    }
                    if (value.length < 6) {
                      return 'Sifre en az 6 karakter olmalidir';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _sifreTekrarController,
                  obscureText: !_sifreTekrarGorunur,
                  decoration: InputDecoration(
                    labelText: 'Sifre Tekrar',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_sifreTekrarGorunur ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _sifreTekrarGorunur = !_sifreTekrarGorunur),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lutfen sifrenizi tekrar giriniz';
                    }
                    if (value.trim() != _sifreController.text.trim()) {
                      return 'Sifreler eslesmiyor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _yukleniyor ? null : _kayitOl,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _yukleniyor
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Kayit Ol', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
