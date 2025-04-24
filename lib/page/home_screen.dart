// ignore_for_file: deprecated_member_use, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  String userName = 'pengguna';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUser();
    _setTanggal();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? '';
    });
  }

  void _setTanggal() async {
    final now = DateTime.now();
    final formatter = DateFormat.EEEE('id_ID').addPattern(', dd MMMM yyyy');
    setState(() {
      currentDate = formatter.format(now);
    });
  }

  Future<void> _absen (String tipe) async {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await DbHelper().insertAbsensi(userEmail, tipe, now, position.latitude, position.longitude);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil Absen')));
  }

  List<Widget> _pages() => [
    _dashboard(),
    RiwayatScreen(userEmail: userEmail),
    ProfilScreen(userEmail: userEmail),
  ];

  Widget _dashboard() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hallow, $userName :)',
            style: TextStyle(
              fontSize: 20
            )),
            SizedBox(height: 4),
            Text(
              currentDate,
              style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _absen('masuk'),
                child: Text('Masuk')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _absen('pulang'), 
                child: Text('Pulang'))
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
      appBar: AppBar(
        title: Text('Absensi'),
      ),
      body: _pages()
        [_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Dashboard'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_sharp),
              label: 'Profil')
          ]),
    );
  }
}