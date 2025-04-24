// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:praujk/database/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nama'),
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final user = await DbHelper().getUserByEmail(widget.userEmail);
              if (user != null) {
                await DbHelper().updateUser(user['id'], _nameController.text, _emailController.text);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('userEmail', _emailController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profil berhasil diperbaharui'))
                );
              }
            },
            child: Text('Simpan Perubahan'),
          )
        ],
      ),
    );
  }
}