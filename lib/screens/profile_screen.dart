import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _adSoyadController;
  late final TextEditingController _ogrenciNoController;
  late final TextEditingController _universiteController;
  late final String _email;

  bool _duzenlemeModu = false;

  late Future<List<Map<String, dynamic>>> _notlarimFuture;

  @override
  void initState() {
    super.initState();
    _adSoyadController =
        TextEditingController(text: ApiService.currentUserAdSoyad ?? '');
    _ogrenciNoController =
        TextEditingController(text: ApiService.currentUserStudentNo ?? '');
    _universiteController =
        TextEditingController(text: ApiService.currentUserUniversite ?? '');
    _email = ApiService.currentUserEmail ?? '';

    _notlarimFuture = _kendiNotlariniGetir();
  }

  Future<List<Map<String, dynamic>>> _kendiNotlariniGetir() async {
    final tumNotlar = await ApiService.getNotes();
    return tumNotlar
        .where((not) => not['user_id'] == ApiService.currentUserId)
        .toList();
  }

  @override
  void dispose() {
    _adSoyadController.dispose();
    _ogrenciNoController.dispose();
    _universiteController.dispose();
    super.dispose();
  }

  void _kaydet() {
    if (_formKey.currentState!.validate()) {
      // TODO: Backend'de bir PUT/PATCH endpoint'i eklenince
      // burada gerçek bir güncelleme isteği gönderilecek.
      setState(() {
        _duzenlemeModu = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgiler güncellendi (örnek)')),
      );
    }
  }

  void _cikisYap() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _notKarti(Map<String, dynamic> not) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.upload_file, color: Colors.deepPurple),
        title: Text(not['baslik']?.toString() ?? ''),
        subtitle: Text(
          '${not['ders_adi'] ?? ''} • ${not['yukleme_tarihi']?.toString().split('T').first ?? ''}',
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }

  Widget _notlarimBolumu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Notlarım',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _notlarimFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Notlar yüklenemedi: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            final notlar = snapshot.data ?? [];
            if (notlar.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Henüz bir not yüklemedin.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }
            return Column(
              children: notlar.map((not) => _notKarti(not)).toList(),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_duzenlemeModu ? Icons.close : Icons.edit),
            tooltip: _duzenlemeModu ? 'Vazgeç' : 'Düzenle',
            onPressed: () {
              setState(() {
                _duzenlemeModu = !_duzenlemeModu;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    child: Icon(Icons.person, size: 56),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _adSoyadController,
                    enabled: _duzenlemeModu,
                    decoration: const InputDecoration(
                      labelText: 'Ad Soyad',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ad soyad boş olamaz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email (değiştirilemez)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ogrenciNoController,
                    enabled: _duzenlemeModu,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Öğrenci Numarası',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Öğrenci numarası boş olamaz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _universiteController,
                    enabled: _duzenlemeModu,
                    decoration: const InputDecoration(
                      labelText: 'Üniversite',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Üniversite boş olamaz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_duzenlemeModu)
                    ElevatedButton.icon(
                      onPressed: _kaydet,
                      icon: const Icon(Icons.save),
                      label: const Text('Kaydet'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _cikisYap,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            _notlarimBolumu(),
          ],
        ),
      ),
    );
  }
}