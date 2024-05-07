import 'package:flutter/material.dart'; //mengimpor pustaka flutter material untuk pembuatan UI
import 'dart:convert'; //mengimpor pustaka dart;convert untuk encoding & decoding JSON
import 'package:http/http.dart' as http; //mengimport http dari package http
// Library untuk state management menggunakan BLoC pattern
import 'package:flutter_bloc/flutter_bloc.dart'; 

// Model untuk menyimpan data universitas
class University {
  final String name;
  final String? stateProvince; //nama usniversitas
  final List<String> domains; //provinsi
  final List<String> webPages; //daftar domain universitas
  final String alphaTwoCode; //kode negara 2 huruf
  final String country; //nama negara

// Konstruktor untuk membuat objek University
  University({
    required this.name,
    this.stateProvince,
    required this.domains,
    required this.webPages,
    required this.alphaTwoCode,
    required this.country,
  });

  // Method untuk membuat objek University dari JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      stateProvince: json['state-province'], // Data ini bisa null
      domains: List<String>.from(json['domains']), // Konversi daftar dari JSON
      webPages: List<String>.from(json['web_pages']), // Sama seperti di atas
      alphaTwoCode: json['alpha_two_code'], // Kode dua huruf negara
      country: json['country'], // Nama negara
    );
  }
}

// Cubit untuk menangani perubahan state universitas
class UniversityCubit extends Cubit<List<University>> {
  UniversityCubit()
      : super([]); // Inisialisasi state awal dengan daftar universitas kosong

  String selectedCountry =
      'Indonesia'; // Menambahkan properti untuk menyimpan negara yang dipilih

  // Method untuk memperbarui daftar universitas berdasarkan negara yang dipilih
  Future<void> fetchUniversities(String country) async {
    // Mengambil data universitas dari API berdasarkan negara yang diberikan
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country'));

    if (response.statusCode == 200) {
      // Jika respons berhasil (status code 200)
      final List<dynamic> data = jsonDecode(response.body);
      // Mengubah data JSON menjadi daftar objek University
      emit(data.map((json) => University.fromJson(json)).toList());
      // Memperbarui state dengan daftar universitas yang baru
    } else {
      // Jika terjadi kesalahan saat mengambil data
      throw Exception('Gagal memuat data universitas');
    }
  }
}

void main() {
  // Fungsi utama yang memulai aplikasi Flutter
  runApp(MyApp()); // Memanggil widget utama aplikasi, yaitu MyApp
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Membangun widget MaterialApp yang merupakan aplikasi utama
    return MaterialApp(
      // Memberikan halaman awal aplikasi
      home: BlocProvider(
        // Membungkus halaman utama dengan BlocProvider
        // Menyediakan instance UniversityCubit untuk digunakan di halaman
        create: (context) => UniversityCubit(),
        child: HomeScreen(), // Menampilkan halaman HomeScreen
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Membangun widget Scaffold sebagai halaman utama
    return Scaffold(
      // Menampilkan AppBar
      appBar: AppBar(
        title: Text('ASEAN Universities'), // Judul di AppBar
      ),
      // Menampilkan konten halaman dengan Column
      body: Column(
        children: [
          // Widget untuk memilih negara menggunakan DropdownButton
          CountryDropdown(),
          // Widget untuk menampilkan daftar universitas menggunakan BlocBuilder
          Expanded(child: UniversityList()),
        ],
      ),
    );
  }
}

class CountryDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mendapatkan instance UniversityCubit dari BlocProvider
    final universityCubit = BlocProvider.of<UniversityCubit>(context);

  // Menggunakan BlocBuilder untuk membangun widget berdasarkan state UniversityCubit
    return BlocBuilder<UniversityCubit, List<University>>(
      builder: (context, universityList) {
        // Membangun widget DropdownButton untuk memilih negara
        return Container(
          padding: EdgeInsets.all(16.0),
          child: DropdownButton<String>(
            value:
                universityCubit.selectedCountry, // Nilai default DropdownButton
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
              // Memetakan daftar negara menjadi DropdownMenuItem
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              // Callback saat nilai DropdownButton berubah
              if (newValue != null) {
                // Memperbarui state selectedCountry pada UniversityCubit
                universityCubit.selectedCountry = newValue;
                // Memuat data universitas berdasarkan negara yang baru dipilih
                universityCubit.fetchUniversities(newValue);
              }
            },
          ),
        );
      },
    );
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UniversityCubit, List<University>>(
      builder: (context, universityList) {
        return ListView.builder(
          // Membuat ListView untuk menampilkan daftar universitas
          itemCount: universityList.length, // Jumlah item di dalam ListView
          itemBuilder: (context, index) {
            // Bagaimana setiap item dibuat
            final university =
                universityList[index]; // Universitas pada indeks saat ini
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
                        university.name, // Nama universitas
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold, // Font tebal untuk nama
                        ),
                      ),
                      SizedBox(height: 8.0), // Spasi antar elemen
                      Row(
                        // Gunakan Row untuk menampilkan beberapa informasi dalam satu baris
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
                          Text(university.domains.join(
                              ', ')), // Tampilkan semua domain,dipisahkan koma
                        ],
                      ),
                      Row(
                        children: [
                          Text('Halaman Web: '), // Label
                          Text(university.webPages.join(
                              ', ')), // Tampilkan semua halaman web,dipisahkan koma
                        ],
                      ),
                      Row(
                        children: [
                          Text('Alpha Two Code: '), // Label
                          Text(university
                              .alphaTwoCode), // Tampilkan kode dua huruf
                        ],
                      ),
                      Row(
                        children: [
                          Text('Negara: '), // Label
                          Text(university.country), // Nama negara
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
