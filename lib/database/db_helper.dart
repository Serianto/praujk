import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Database? _db;

  Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'praujk.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT)''');

        await db.execute('''
          CREATE TABLE absensi(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT,
            tipe TEXT,
            waktu TEXT,
            latitude REAL,
            longitude REAL)''');
      },
    ); 
  }

  Future<int> registerUser (
    String name,
    String email,
    String password,
  ) async {
    final dbClient = await db;
    return await dbClient.insert(
      'users', {
        'name' : name,
        'email' : email,
        'password' : password,
      });
  }

  Future<Map<String, dynamic>?> loginUser (
    String email,
    String password,
  ) async {
    final dbClient = await db;
    final result = await dbClient.query('users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> insertAbsensi(
    String email,
    String tipe,
    String waktu,
    double lat,
    double long
  ) async {
    final dbClient = await db;
    return await dbClient.insert(
      'absensi', {
        'email' : email,
        'tipe' : tipe,
        'waktu' : waktu,
        'latitude' : lat,
        'longitude' : long,
      });
  }

  Future<Map<String, dynamic>?> getUserByEmail(
    String email) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'users',
      where: 'email = ? ',
      whereArgs: [email]);
      if(result.isNotEmpty) return result.first;
      return null;
  }

  Future<int> updateUser(
    int id,
    String name,
    String email
  ) async {
    final dbClient = await db;
    return await dbClient.update(
      'users', {
        'name' : name,
        'email' : email},
        where: 'id = ?',
        whereArgs: [id]);
  }
}