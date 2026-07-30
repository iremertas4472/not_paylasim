import 'dart:io';
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
    'Selcuk Universitesi',
    'Gida Tarim Universitesi',
    'Aksaray Üniversitesi',
    'Konya Teknik Üniversitesi',
    'Necmettin Erbakan Üniversitesi',
  ];

  final List<String> _programTurleri = ['Onlisans', 'Lisans'];

  final Map<String, List<String>> _sinifSecenekleri = {
    'Onlisans': ['1', '2'],
    'Lisans': ['Hazirlik', '1', '2', '3', '4'],
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
      _hataGoster('Dosya secilirken bir hata olustu: $e');
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
      _hataGoster('Lutfen bir dosya secin.');
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      await ApiService.createNote(
  baslik: _baslikController.text.trim(),
  aciklama: _aciklamaController.text.trim(),
  dersAdi: _dersAdiController.text.trim(),
  dosya: File(_secilenDosya!.path!),
);
      _basariGoster('Not basariyla yuklendi!');

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
      _hataGoster('Yukleme sirasinda bir hata olustu: $e');
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
          'Not Yukle',
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
              DropdownButtonFormField<String>(
                initialValue: _selectedUniversite,
                decoration: _inputDecoration('Universite secin', Icons.school),
                items: _universiteler
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedUniversite = value);
                },
                validator: (value) =>
                    value == null ? 'Lutfen universite secin' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedProgramTuru,
                decoration:
                    _inputDecoration('Program turu secin', Icons.category),
                items: _programTurleri
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProgramTuru = value;
                    _selectedSinif = null;
                  });
                },
                validator: (value) =>
                    value == null ? 'Lutfen program turu secin' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSinif,
                decoration: _inputDecoration('Sinif secin', Icons.class_),
                items: (_selectedProgramTuru == null
                        ? <String>[]
                        : _sinifSecenekleri[_selectedProgramTuru!] ?? [])
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedSinif = value);
                },
                validator: (value) =>
                    value == null ? 'Lutfen sinif secin' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dersAdiController,
                decoration: _inputDecoration('Ders adi', Icons.menu_book),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Lutfen ders adi girin'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _baslikController,
                decoration: _inputDecoration('Not basligi', Icons.title),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Lutfen bir baslik girin'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aciklamaController,
                maxLines: 3,
                decoration: _inputDecoration('Aciklama', Icons.description),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Lutfen bir aciklama girin'
                    : null,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _dosyaSec,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _secilenDosya == null ? 'Dosya Sec' : _secilenDosya!.name,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _yukleniyor ? null : _notuYukle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _yukleniyor
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Notu Yukle',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
