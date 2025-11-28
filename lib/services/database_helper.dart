import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (Platform.isWindows) {
      // Utiliser un chemin plus fiable sur Windows
      final appDataDir = Platform.environment['LOCALAPPDATA'] ??
          Platform.environment['APPDATA'];
      if (appDataDir != null) {
        final dir = Directory('$appDataDir\\IdealCalcule');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        path = join(dir.path, 'ideal_calcule.db');
      } else {
        // Fallback
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        path = join(documentsDirectory.path, 'ideal_calcule.db');
      }
    } else {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'ideal_calcule.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        // Activer les contraintes de clés étrangères
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        logoPath TEXT,
        contactInfo TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE supports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        currentPrice REAL,
        supplier TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE articles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER,
        name TEXT,
        dimensions TEXT,
        supportId INTEGER,
        FOREIGN KEY(clientId) REFERENCES clients(id) ON DELETE CASCADE,
        FOREIGN KEY(supportId) REFERENCES supports(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE price_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supportId INTEGER,
        price REAL,
        date TEXT,
        supplier TEXT,
        FOREIGN KEY(supportId) REFERENCES supports(id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD Operations

  // Clients
  Future<int> insertClient(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert('clients', row);
    } catch (e) {
      print('❌ Erreur insertion client: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getClients() async {
    try {
      Database db = await database;
      return await db.query('clients');
    } catch (e) {
      print('❌ Erreur récupération clients: $e');
      return [];
    }
  }

  Future<int> updateClient(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      int id = row['id'];
      return await db.update('clients', row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur mise à jour client: $e');
      rethrow;
    }
  }

  Future<int> deleteClient(int id) async {
    try {
      Database db = await database;
      return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur suppression client: $e');
      rethrow;
    }
  }

  // Supports
  Future<int> insertSupport(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert('supports', row);
    } catch (e) {
      print('❌ Erreur insertion support: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSupports() async {
    try {
      Database db = await database;
      return await db.query('supports');
    } catch (e) {
      print('❌ Erreur récupération supports: $e');
      return [];
    }
  }

  Future<int> updateSupport(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      int id = row['id'];
      return await db.update('supports', row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur mise à jour support: $e');
      rethrow;
    }
  }

  Future<int> deleteSupport(int id) async {
    try {
      Database db = await database;
      return await db.delete('supports', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur suppression support: $e');
      rethrow;
    }
  }

  // Articles
  Future<int> insertArticle(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert('articles', row);
    } catch (e) {
      print('❌ Erreur insertion article: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getArticlesByClient(int clientId) async {
    try {
      Database db = await database;
      return await db
          .query('articles', where: 'clientId = ?', whereArgs: [clientId]);
    } catch (e) {
      print('❌ Erreur récupération articles: $e');
      return [];
    }
  }

  Future<int> deleteArticle(int id) async {
    try {
      Database db = await database;
      return await db.delete('articles', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur suppression article: $e');
      rethrow;
    }
  }

  // Price History
  Future<int> insertPriceHistory(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert('price_history', row);
    } catch (e) {
      print('❌ Erreur insertion historique prix: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPriceHistory(int supportId) async {
    try {
      Database db = await database;
      return await db.query('price_history',
          where: 'supportId = ?', whereArgs: [supportId], orderBy: 'date DESC');
    } catch (e) {
      print('❌ Erreur récupération historique prix: $e');
      return [];
    }
  }
}
