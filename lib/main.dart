import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AplikasiDoaApp());
}

class AplikasiDoaApp extends StatelessWidget {
  const AplikasiDoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kumpulan Doa Harian',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HalamanDaftarDoa(),
    );
  }
}

class HalamanDaftarDoa extends StatefulWidget {
  const HalamanDaftarDoa({super.key});

  @override
  State<HalamanDaftarDoa> createState() => _HalamanDaftarDoaState();
}

class _HalamanDaftarDoaState extends State<HalamanDaftarDoa> {
  List<dynamic> _semuaDoa = [];
  List<dynamic> _doaTampil = [];
  bool _sedangMemuat = true;
  String? _pesanError;
  final TextEditingController _searchController = TextEditingController();

  // Endpoint utama API Doa Harian
  final String _apiUrl = 'https://doa-doa-api-ahmadramadhan.fly.dev/api';

  @override
  void initState() {
    super.initState();
    _ambilDataDoa();
  }

  Future<void> _ambilDataDoa() async {
    setState(() {
      _sedangMemuat = true;
      _pesanError = null;
    });

    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        // Menggunakan utf8.decode agar teks huruf Arab tidak rusak (garbled)
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _semuaDoa = data;
          _doaTampil = data;
          _sedangMemuat = false;
        });
      } else {
        throw Exception('Server merespons dengan status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _sedangMemuat = false;
        _pesanError = 'Gagal terhubung ke API ($e).';
      });
    }
  }

  void _filterDoa(String kataKunci) {
    if (kataKunci.isEmpty) {
      setState(() {
        _doaTampil = _semuaDoa;
      });
      return;
    }

    final hasilFilter = _semuaDoa.where((item) {
      final judul = (item['doa'] ?? '').toString().toLowerCase();
      final arti = (item['artinya'] ?? '').toString().toLowerCase();
      final input = kataKunci.toLowerCase();
      return judul.contains(input) || arti.contains(input);
    }).toList();

    setState(() {
      _doaTampil = hasilFilter;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Kumpulan Doa Harian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Data',
            onPressed: _ambilDataDoa,
          ),
        ],
      ),
      body: Column(
        children: [
          // Kolom Pencarian
          Container(
            color: Colors.teal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterDoa,
              decoration: InputDecoration(
                hintText: 'Cari judul doa atau terjemahan...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterDoa('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Area Konten Utama
          Expanded(
            child: _bangunKontenUtama(),
          ),
        ],
      ),
    );
  }

  Widget _bangunKontenUtama() {
    if (_sedangMemuat) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 12),
            Text('Mengambil data doa dari server...'),
          ],
        ),
      );
    }

    if (_pesanError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _pesanError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _ambilDataDoa,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_doaTampil.isEmpty) {
      return const Center(
        child: Text('Doa yang dicari tidak ditemukan.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _ambilDataDoa,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _doaTampil.length,
        itemBuilder: (context, index) {
          final item = _doaTampil[index];
          return _itemKartuDoa(
            id: item['id']?.toString() ?? '${index + 1}',
            judul: item['doa'] ?? 'Tanpa Judul',
            ayat: item['ayat'] ?? '',
            latin: item['latin'] ?? '',
            arti: item['artinya'] ?? '',
          );
        },
      ),
    );
  }

  Widget _itemKartuDoa({
    required String id,
    required String judul,
    required String ayat,
    required String latin,
    required String arti,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Navigasi ke Halaman Detail Doa
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HalamanDetailDoa(
                judul: judul,
                ayat: ayat,
                latin: latin,
                arti: arti,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    foregroundColor: Colors.teal.shade900,
                    radius: 18,
                    child: Text(
                      id,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      judul,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const Divider(height: 24),
              // Teks Arab (Rata Kanan / RTL)
              Text(
                ayat,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              // Cuplikan Terjemahan
              Text(
                arti,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman Kedua (Detail Bacaan Doa Lengkap)
class HalamanDetailDoa extends StatelessWidget {
  final String judul;
  final String ayat;
  final String latin;
  final String arti;

  const HalamanDetailDoa({
    super.key,
    required this.judul,
    required this.ayat,
    required this.latin,
    required this.arti,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(judul),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  judul,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const Divider(height: 30),
                Text(
                  ayat,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 2.0,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  latin,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.teal.shade800,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Artinya:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '"$arti"',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}