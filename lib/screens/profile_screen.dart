import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // TODO: Backend hazır olunca bu değerler, giriş yapan kullanıcının
  // gerçek verileriyle (API'den gelen) doldurulacak.
  final TextEditingController _adSoyadController =
      TextEditingController(text: 'Ahmet Yılmaz');
  final TextEditingController _ogrenciNoController =
      TextEditingController(text: '20231234');
  final TextEditingController _universiteController =
      TextEditingController(text: 'Selçuk Üniversitesi');

  // Email değiştirilemez, sadece görüntülenir (hesap doğrulaması buna bağlı)
  final String _email = 'ornek@ogr.selcuk.edu.tr';

  bool _duzenlemeModu = false;

  // ---------------------------------------------------------
  // Notlarım bölümü için state ve mock veri
  // TODO: Backend hazır olunca bu iki liste, giriş yapan kullanıcının
  // gerçek "yüklediği notlar" (notes tablosunda user_id = kendisi olanlar)
  // ve "kaydettiği notlar" (favoriler tablosundan) verisiyle doldurulacak.
  // ---------------------------------------------------------
  int _secilenSekme = 0; // 0: Yüklenenler, 1: Kaydedilenler

  final List<Map<String, String>> _yuklenenNotlar = [
    {'baslik': '1. Vize Özeti', 'ders': 'Matematik', 'tarih': '12.03.2026'},
    {'baslik': 'Ödev Çözümleri', 'ders': 'Fizik', 'tarih': '02.04.2026'},
  ];

  final List<Map<String, String>> _kaydedilenNotlar = [
    {'baslik': 'Final Konu Tekrarı', 'ders': 'Kimya', 'yukleyen': 'Elif K.'},
    {'baslik': 'Ders Notları - Hafta 3', 'ders': 'Biyoloji', 'yukleyen': 'Mert S.'},
    {'baslik': 'Lab Raporu Örneği', 'ders': 'Fizik', 'yukleyen': 'Zeynep A.'},
  ];

  @override
  void dispose() {
    _adSoyadController.dispose();
    _ogrenciNoController.dispose();
    _universiteController.dispose();
    super.dispose();
  }

  void _kaydet() {
    if (_formKey.currentState!.validate()) {
      // TODO: Backend hazır olunca burada gerçek bir güncelleme isteği
      // (PUT/PATCH) gönderilecek.
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

  // Notlarım bölümündeki sekme geçiş butonu
  Widget _sekmeButonu(String baslik, int index) {
    final secili = _secilenSekme == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _secilenSekme = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: secili ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: secili ? Colors.deepPurple : Colors.grey[400]!,
            ),
          ),
          child: Text(
            baslik,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secili ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // Not listesini gösteren kart yapısı
  Widget _notKarti(Map<String, String> not, {required bool yuklenen}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          yuklenen ? Icons.upload_file : Icons.bookmark,
          color: Colors.deepPurple,
        ),
        title: Text(not['baslik'] ?? ''),
        subtitle: Text(
          yuklenen
              ? '${not['ders']} • ${not['tarih']}'
              : '${not['ders']} • ${not['yukleyen']}',
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {
          // TODO: Not detay ekranı hazır olunca buraya yönlendirme eklenecek.
        },
      ),
    );
  }

  Widget _notlarimBolumu() {
    final gosterilecekListe =
        _secilenSekme == 0 ? _yuklenenNotlar : _kaydedilenNotlar;
    final yuklenenMi = _secilenSekme == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Notlarım',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _sekmeButonu('Yüklenenler', 0),
            const SizedBox(width: 8),
            _sekmeButonu('Kaydedilenler', 1),
          ],
        ),
        const SizedBox(height: 16),
        if (gosterilecekListe.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                yuklenenMi
                    ? 'Henüz bir not yüklemedin.'
                    : 'Henüz kaydedilen bir not yok.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...gosterilecekListe
              .map((not) => _notKarti(not, yuklenen: yuklenenMi)),
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

                  // Ad Soyad
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

                  // Email (salt okunur)
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

                  // Öğrenci No
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

                  // Üniversite
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