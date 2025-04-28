import 'package:flutter/material.dart';
import 'package:praujk/database/db_helper.dart';

class RiwayatScreen extends StatefulWidget {
  final String userEmail;

  const RiwayatScreen({super.key, required this.userEmail});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late Future<List<Map<String, dynamic>>> _riwayatFuture;

  @override
  void initState() {
    super.initState();
    _riwayatFuture = _fetchRiwayat();
  }

  Future<List<Map<String, dynamic>>> _fetchRiwayat() {
    return DbHelper().getRiwayatByEmail(widget.userEmail);
  }

  Future<void> _hapusRiwayat() async {
    final db = await DbHelper().db;
    await db.delete(
      'absensi',
      where: 'email = ?',
      whereArgs: [widget.userEmail],
    );

    // Setelah menghapus, refresh data untuk UI
    setState(() {
      _riwayatFuture = _fetchRiwayat(); // Memuat ulang riwayat setelah dihapus
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _riwayatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text('Belum ada riwayat absensi'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('${item['tipe'].toString().toUpperCase()} - ${item['waktu']}'),
                  subtitle: Text('Lat: ${item['latitude']}, Long: ${item['longitude']}'),
                  leading: Icon(
                    item['tipe'] == 'masuk' ? Icons.login : Icons.logout,
                    color: item['tipe'] == 'masuk' ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _hapusRiwayat,
        child: const Icon(Icons.delete_forever),
        tooltip: 'Hapus Semua Riwayat',
      ),
    );
  }
}