// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:praujk/database/db_helper.dart';

class RiwayatScreen extends StatelessWidget {
  final String userEmail;

  const RiwayatScreen({super.key, required this.userEmail});

  Future<List<Map<String, dynamic>>> _getRiwayatAbsensi() async {
    final db = await DbHelper().db;
    return await db.query(
      'absensi',
      where: 'email = ?',
      whereArgs: [userEmail],
      orderBy: 'waktu DESC'
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getRiwayatAbsensi(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return Center(child: Text('Belum ada data absensi'));

        Map<String, Map<String, Map<String, dynamic>>> grouped = {};

        for (var absen in snapshot.data!) {
          final date = absen['waktu'].split(' ')[0];
          final tipe = absen['tipe'];
          grouped[date] ??= {};
          grouped[date]![tipe] = absen;
        }

        return ListView(
          padding: EdgeInsets.all(16),
          children: grouped.entries.map((entry) {
            final date = entry.key;
            final masuk = entry.value['masuk'];
            final pulang = entry.value['pulang'];

            return Card(
              child: ListTile(
                title: Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.parse(date))
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Masuk : ${masuk != null ? masuk['waktu'].split(' ')[1] : '-'}'),
                    Text('Pulang : ${pulang != null ? pulang['waktu'].split(' ')[1] : '-'}'),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }
    );
  }
}