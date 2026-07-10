import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<String> _universiteler = [
    'Selçuk Üniversitesi',
    'Gıda Tarım Üniversitesi',
  ];

  final List<String> _programTurleri = ['Önlisans', 'Lisans'];

  final Map<String, List<String>> _sinifSecenekleri = {
    'Önlisans': ['1', '2'],
    'Lisans': ['Hazırlık', '1', '2', '3', '4'],
  };

  String? _seciliUniversite;
  String? _seciliProgramTuru;
  String? _seciliSinif;
  final TextEditingController _dersController = TextEditingController();

  List<Map<String, dynamic>> _sonuclar = [];
  bool _aramaYapildi = false;
  bool _yukleniyor = false;
  String? _hataMesaji;

  Future<void> _aramaYap() async {
    final dersAdi = _dersController.text.trim().toLowerCase();

    setState(() {
      _yukleniyor = true;
      _hataMesaji = null;
    });

    try {
      // TODO: Backend'e üniversite/program türü/sınıf filtreleme eklenince
      // bu parametreler de API'ye gönderilecek. Şimdilik sadece ders adına
      // göre, gerçek veritabanından gelen notlar üzerinden yerel filtreleme yapıyoruz.
      final tumNotlar = await ApiService.getNotes();

      final filtrelenmis = tumNotlar.where((not) {
        final notDersAdi = (not['ders_adi'] ?? '').toString().toLowerCase();
        return dersAdi.isEmpty || notDersAdi.contains(dersAdi);
      }).toList();

      setState(() {
        _sonuclar = filtrelenmis;
        _aramaYapildi = true;
        _yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        _hataMesaji = 'Notlar yüklenirken bir hata oluştu: $e';
        _yukleniyor = false;
      });
    }
  }

  @override
  void dispose() {
    _dersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Ara'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üniversite Seçimi
            DropdownButtonFormField<String>(
              value: _seciliUniversite,
              decoration: const InputDecoration(
                labelText: 'Üniversite',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              items: _universiteler
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _seciliUniversite = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Program Türü Seçimi
            DropdownButtonFormField<String>(
              value: _seciliProgramTuru,
              decoration: const InputDecoration(
                labelText: 'Program Türü',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
              ),
              items: _programTurleri
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _seciliProgramTuru = value;
                  _seciliSinif = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Sınıf Seçimi (Program Türüne göre değişir)
            DropdownButtonFormField<String>(
              value: _seciliSinif,
              decoration: const InputDecoration(
                labelText: 'Sınıf',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grade),
              ),
              items: (_seciliProgramTuru == null
                      ? <String>[]
                      : _sinifSecenekleri[_seciliProgramTuru]!)
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: _seciliProgramTuru == null
                  ? null
                  : (value) {
                      setState(() {
                        _seciliSinif = value;
                      });
                    },
            ),
            const SizedBox(height: 16),

            // Ders Adı
            TextField(
              controller: _dersController,
              decoration: const InputDecoration(
                labelText: 'Ders Adı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.menu_book),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _yukleniyor ? null : _aramaYap,
              icon: _yukleniyor
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(_yukleniyor ? 'Aranıyor...' : 'Ara'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            // Sonuçlar
            Expanded(
              child: _hataMesaji != null
                  ? Center(
                      child: Text(
                        _hataMesaji!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : !_aramaYapildi
                      ? const Center(
                          child: Text(
                            'Aramak için yukarıdaki alanları doldur.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : _sonuclar.isEmpty
                          ? const Center(
                              child: Text(
                                'Sonuç bulunamadı.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _sonuclar.length,
                              itemBuilder: (context, index) {
                                final not = _sonuclar[index];
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.description),
                                    title: Text(not['baslik'] ?? 'İsimsiz Not'),
                                    subtitle: Text(
                                      '${not['ders_adi'] ?? ''} • ${not['ad_soyad'] ?? ''}',
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}