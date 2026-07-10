import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Giriş ekranının yolu

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Öğrenci Not Paylaşım',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      // Uygulama açıldığında ilk olarak LoginScreen ekranı gelsin
      home: const LoginScreen(), 
    );
  }
}