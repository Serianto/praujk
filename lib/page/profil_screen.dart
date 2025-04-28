// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:praujk/database/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:praujk/page/login_screen.dart'; // Import LoginScreen

class ProfilScreen extends StatefulWidget {
  final String userEmail;
  const ProfilScreen({super.key, required this.userEmail});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await DbHelper().getUserByEmail(widget.userEmail);
    if (user != null) {
      setState(() {
        _nameController.text = user['name'];
        _emailController.text = user['email'];
      });
    }
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Menghapus status login
    await prefs.remove('userEmail'); // Menghapus email pengguna

    // Arahkan pengguna kembali ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.green,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  readOnly: true, // Email sebaiknya tidak diedit
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final user = await DbHelper().getUserByEmail(widget.userEmail);
                    if (user != null) {
                      // Simpan perubahan nama ke database
                      await DbHelper().updateUser(user['id'], _nameController.text, _emailController.text);
                      
                      // Simpan nama baru ke SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('userName', _nameController.text);  // Simpan nama yang baru

                      // Menampilkan dialog sebagai notifikasi
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Sukses'),
                            content: Text('Profil berhasil diperbaharui, silakan login ulang'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Kembali ke HomeScreen setelah dialog ditutup
                                  Navigator.pop(context); // Menutup dialog
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())); // Kembali ke HomeScreen
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('Simpan Perubahan'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    side: BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}