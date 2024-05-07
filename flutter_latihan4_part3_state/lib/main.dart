import 'package:flutter/material.dart'; //mengimpor pustaka flutter material untuk pembuatan UI
import 'dart:convert'; //mengimpor pustaka dart;convert untuk encoding&decoding JSON
import 'package:http/http.dart' as http; //mengimport http dari package http
import 'package:provider/provider.dart'; //megimport package provider

class University {
  //model untuk menyimpan data universitas
  final String name;
  final String? stateProvince; //nama usniversitas
  final List<String> domains; //provinsi
  final List<String> webPages; //daftar domain universitas
  final String alphaTwoCode; //kode negara 2 huruf
  final String country; //nama negara

  // Konstruktor untuk membuat objek universitas
  University({
    required this.name,
    this.stateProvince,
    required this.domains,
    required this.webPages,
    required this.alphaTwoCode,
    required this.country,
  });

  //method untuk membuat object universitas dari JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], //mengambil nama universitas dari JSON
      stateProvince: json['state-province'], //mengambil provinsi
      domains: List<String>.from(
          json['domains']), //mengambil domain universitas dari JSON
      webPages: List<String>.from(
          json['web_pages']), //mengambil halaman web universitas dari JSON
      alphaTwoCode:
          json['alpha_two_code'], //mengambil kode alpha 2 hiruf dari JSON
      country: json['country'], //mengambil nama negara dari JSON
    );
  }
}

//method untuk melakukan pemanggilan API untuk mendapatkan daftar universitas
Future<List<University>> fetchUniversities(String country) async {
  final response = await http.get(
      //memanggil API untuk mendapatkan daftar universitas Indonesia
      Uri.parse('http://universities.hipolabs.com/search?country=$country'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body); //parsing data JSON
    return data
        .map((json) => University.fromJson(json))
        .toList(); //mengembalikan daftar uninversitas berdasarkan data JSON
  } else {
    //melemparkan exeption jika gagal memuat data universitas
    throw Exception('Gagal memuat data universitas');
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      //menggunakan ChangeNotifierProvider untuk membuat state global
      //membuat instance pada data UniversitasProvider sebagai state global
      create: (context) => UniversityProvider(),
      child: MyApp(), //menjalankan aplikasi MyApp
    ),
  );
}

class UniversityProvider with ChangeNotifier {
  List<University> _universities = []; //menyimpan daftar universitas
  String _selectedCountry =
      'Indonesia'; //menyimpan negara yang pilih secara default

  List<University> get universities =>
      _universities; //getter untuk mendapatkan daftar universitas
  String get selectedCountry =>
      _selectedCountry; //getter untuk mendaptkan negara yang dipilih

  void setSelectedCountry(String country) {
    _selectedCountry = country; //mengatur negara yang dipilih dengan nilai baru
    fetchUniversities(country).then((universities) {
      _universities =
          universities; //mengatur daftar universitas dengan hasil pemanggilan API terbaru
      notifyListeners(); //memberitahu pendengar tentang perubahan state
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Menampilkan aplikasi MaterialApp
      home: Scaffold(
        // Menampilkan halaman Scaffold
        appBar: AppBar(
          // Menampilkan AppBar
          title: Text('ASEAN Universities'), //judul AppBar
        ),
        body: Column(
          // Menampilkan widget Column
          children: [
            //menggunakan consumer untuk mendengarkan perubahan pada UniversitasProvider
            Consumer<UniversityProvider>(
              builder: (context, universityProvider, _) {
                // Builder untuk menampilkan widget DropdownButton
                return DropdownButton<String>(
                  // Menampilkan DropdownButton
                  value: universityProvider.selectedCountry,
                  // Nilai yang dipilih dari state UniversityProvider
                  items: <String>[
                    // Daftar item untuk DropdownButton
                    // Daftar negara ASEAN
                    'Indonesia',
                    'Singapore',
                    'Malaysia',
                    'Thailand',
                    'Philippines',
                    'Vietnam',
                    'Myanmar',
                    'Cambodia',
                    'Brunei',
                    'Laos',
                  ].map<DropdownMenuItem<String>>((String value) {
                    // Memetakan daftar item menjadi DropdownMenuItem
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // Callback saat nilai DropdownButton berubah
                    universityProvider.setSelectedCountry(newValue!);
                  },
                );
              },
            ),
            Expanded(
              // Menampilkan widget Expanded
              child: Consumer<UniversityProvider>(
                // Menggunakan Consumer untuk mendengarkan perubahan pada UniversityProvider
                builder: (context, universityProvider, _) {
                  if (universityProvider.universities.isNotEmpty) {
                    // Jika ada data universitas, tampilkan ListView
                    return ListView.builder(
                      itemCount: universityProvider.universities.length,
                      // Jumlah item di ListView
                      itemBuilder: (context, index) {
                        // Membangun widget untuk setiap item
                        final university = universityProvider.universities[
                            index]; // Universitas pada indeks saat ini
                        return Padding(
                          // Beri padding pada setiap item
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            // Menampilkan data universitas dalam Card
                            child: Padding(
                              // Beri padding dalam Card
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                // Menggunakan Column untuk mengatur tampilan data universitas
                                crossAxisAlignment:
                                    CrossAxisAlignment.start, // Align ke kiri
                                children: [
                                  Text(
                                    university
                                        .name, // Menampilkan nama universitas
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight
                                          .bold, // Font tebal untuk nama
                                    ),
                                  ),
                                  SizedBox(height: 8.0), // Spasi antar elemen
                                  Row(
                                    children: [
                                      Text('Provinsi: '), // Label
                                      Text(
                                        university.stateProvince ?? 'Tidak ada',
                                        // Menampilkan provinsi,atau 'Tidak ada' jika tidak ada
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Domain: '), // Label
                                      Text(university.domains.join(', ')),
                                      // Menampilkan daftar domain universitas
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Halaman Web: '), // Label
                                      Text(university.webPages.join(', ')),
                                      // Menampilkan daftar halaman web universitas
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Alpha Two Code: '), // Label
                                      Text(university.alphaTwoCode),
                                      // Menampilkan kode alpha dua huruf universitas
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Negara: '),
                                      Text(university.country),
                                      // Menampilkan nama negara universitas
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    // Jika tidak ada data universitas, tampilkan container kosong
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
