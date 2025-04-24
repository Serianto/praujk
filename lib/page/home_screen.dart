// ignore_for_file: deprecated_member_use, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:praujk/database/db_helper.dart';
import 'package:praujk/page/profil_screen.dart';
import 'package:praujk/page/riwayat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String currentDate = '';
  String userEmail = '';
  String userName = '';
  String userLocation = 'Memuat lokasi...';
  String absenMasuk = 'Belum Absen Masuk';
  String absenPulang = 'Belum Absen Pulang';
  double? latitudeMasuk;
  double? longitudeMasuk;
  double? latitudeKeluar;
  double? longitudeKeluar;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _setTanggal();
    _getUserLocation();
    _loadAbsensiMasuk();
    _loadAbsensiKeluar();
    _loadKoorMasuk();
    _loadKoorKeluar();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? '';
      userName = prefs.getString('userName') ?? 'Pengguna';
    });
  }

void _setTanggal() async {
  final now = DateTime.now();
  final formatter = DateFormat("EEEE, dd MMMM yyyy", "id_ID");
  setState(() {
    currentDate = formatter.format(now);
  });
}

  Future<LatLng?> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _absen(String tipe) async {
    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd -- HH:mm:ss').format(now);
    String absenText = tipe == 'masuk' ? 'Absen Masuk' : 'Absen Pulang';

    // Ambil lokasi
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('absen$tipe', formattedTime);
    await prefs.setDouble('latitude$tipe', position.latitude);
    await prefs.setDouble('longitude$tipe', position.longitude);

    final db = await DbHelper().db;
    await db.insert('absensi', {
    'email': prefs.getString('userEmail'),
    'waktu': formattedTime,
    'tipe': tipe,
    'latitude': position.latitude,
    'longitude': position.longitude,
  });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$absenText berhasil pada $formattedTime\nLokasi: ${position.latitude}, ${position.longitude}',
        ),
      ),
    );
    _loadAbsensiMasuk();
  }

Future<void> _pulang(String tipe) async {
  final now = DateTime.now();
  final formattedTime = DateFormat('yyyy-MM-dd -- HH:mm:ss').format(now);
  String absenText = tipe == 'keluar' ? 'Absen Pulang' : 'Absen Masuk';

  // Ambil lokasi
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('absen$tipe', formattedTime); 
  await prefs.setDouble('latitude$tipe', position.latitude);
  await prefs.setDouble('longitude$tipe', position.longitude);

  final db = await DbHelper().db;
  await db.insert('absensi', {
    'email': prefs.getString('userEmail'),
    'waktu': formattedTime,
    'tipe': tipe,
    'latitude': position.latitude,
    'longitude': position.longitude,
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '$absenText berhasil pada $formattedTime\nLokasi: ${position.latitude}, ${position.longitude}',
      ),
    ),
  );


  _loadAbsensiKeluar();
}

  void _loadAbsensiMasuk() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      absenMasuk = prefs.getString('absenmasuk') ?? 'Belum Absen Masuk';
    });
  }

void _loadAbsensiKeluar() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    absenPulang = prefs.getString('absenkeluar') ?? 'Belum Absen Pulang';
  });
}

  void _loadKoorMasuk() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      latitudeMasuk = prefs.getDouble('latitudemasuk');
      longitudeMasuk = prefs.getDouble('longitudemasuk');
    });
  }

  void _loadKoorKeluar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      latitudeKeluar = prefs.getDouble('latitudekeluar');
      longitudeKeluar = prefs.getDouble('longitudekeluar');
    });
  }

  List<Widget> _pages() => [
        _dashboard(),
        RiwayatScreen(userEmail: userEmail),
        ProfilScreen(userEmail: userEmail),
      ];

  Widget _dashboard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $userName!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            currentDate.isEmpty ? 'Loading...' : currentDate,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 20),

          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: FutureBuilder<LatLng?>(
              future: _getUserLocation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Tidak dapat mengakses lokasi'));
                }

                final latLng = snapshot.data!;

                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: latLng,
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('lokasiSaya'),
                      position: latLng,
                      infoWindow: const InfoWindow(title: 'Lokasi Anda'),
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                );
              },
            ),
          ),
          Center(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _absen('masuk'),
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text(
                        'Absen Masuk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _pulang('keluar'),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Absen Keluar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Absen Masuk: $absenMasuk',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Absen Pulang: $absenPulang',
                      style: const TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Absensi')),
      body: _pages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Absensi'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}