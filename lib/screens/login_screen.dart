import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';
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
  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
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
), // TextFormField

              const SizedBox(height: 24),

             ElevatedButton(
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      // TODO: Backend hazır olunca burası gerçek giriş isteği ile değişecek
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  },
  child: const Text("Giriş Yap"),
), // ElevatedButton

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