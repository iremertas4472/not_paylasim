import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _universiteler = [
    'Selçuk Üniversitesi',
    'Gıda Tarım Üniversitesi',
  ];

  final List<String> _programTurleri = ['Önlisans', 'Lisans'];

  final Map<String, List<String>> _sinifSecenekleri = {
    'Önlisans': ['1', '2'],
    'Lisans': ['Hazırlık', '1', '2', '3', '4'],
  };

  String? _selectedUniversite;
  String? _selectedProgramTuru;
  String? _selectedSinif;
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _dersAdiController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  PlatformFile? _secilenDosya;
  bool _yukleniyor = false;

  @override
  void dispose() {
    _baslikController.dispose();
    _dersAdiController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _dosyaSec() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _secilenDosya = result.files.first;
        });
      }
    } catch (e) {
      _hataGoster('Dosya seçilirken bir hata oluştu: $e');
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: Colors.red),
    );
  }

  void _basariGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: Colors.green),
    );
  }

  Future<void> _notuYukle() async {
    if (!_formKey.currentState!.validate()) return;

    if (_secilenDosya == null) {
      _hataGoster('Lütfen bir dosya seçin.');
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      // TODO: Şu an sadece dosya adı kaydediliyor. Gerçek dosya yükleme
      // (bulut depolama vb.) sonraki adımda eklenecek.
      await ApiService.createNote(
        baslik: _baslikController.text.trim(),
        aciklama: _aciklamaController.text.trim(),
        dersAdi: _dersAdiController.text.trim(),
        dosyaAdi: _secilenDosya!.name,
      );

      _basariGoster('Not başarıyla yüklendi!');

      setState(() {
        _selectedUniversite = null;
        _selectedProgramTuru = null;
        _selectedSinif = null;
        _baslikController.clear();
        _dersAdiController.clear();
        _aciklamaController.clear();
        _secilenDosya = null;
      });
    } catch (e) {
      _hataGoster('Yükleme sırasında bir hata oluştu: $e');
    } finally {
      setState(() => _yukleniyor = false);
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF3FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Not Yükle',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              //
              