import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert'; // For JSON encoding in trash

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
      final appDataDir = Platform.environment['LOCALAPPDATA'] ??
          Platform.environment['APPDATA'];
      if (appDataDir != null) {
        final dir = Directory('$appDataDir\\IdealCalcule');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        path = join(dir.path, 'ideal_calcule.db');
      } else {
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        path = join(documentsDirectory.path, 'ideal_calcule.db');
      }
    } else {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'ideal_calcule.db');
    }

    return await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Clients
    await db.execute('''
      CREATE TABLE clients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        logoPath TEXT,
        contactInfo TEXT
      )
    ''');

    // Supports
    await db.execute('''
      CREATE TABLE supports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        currentPrice REAL,
        supplier TEXT
      )
    ''');

    // Articles
    await db.execute('''
      CREATE TABLE articles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER,
        name TEXT,
        photo TEXT,
        type TEXT,
        typeAutre TEXT,
        supportId INTEGER,
        costPrice REAL,
        repeat REAL,
        poseCount INTEGER,
        amalgam INTEGER,
        width REAL,
        machine TEXT,
        colorCount INTEGER,
        sleeveCase REAL,
        labelsPerReel INTEGER,
        core TEXT,
        FOREIGN KEY(clientId) REFERENCES clients(id) ON DELETE CASCADE,
        FOREIGN KEY(supportId) REFERENCES supports(id)
      )
    ''');

    // Price History
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

    // Machines
    await db.execute('''
      CREATE TABLE machines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT NOT NULL,
        typeId INTEGER NOT NULL,
        laize REAL,
        develop_min REAL,
        develop_max REAL,
        vitesse INTEGER,
        cout_horaire REAL,
        description TEXT
      )
    ''');

    // Repeats
    await db.execute('''
      CREATE TABLE repeats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT NOT NULL,
        nbrDents INTEGER NOT NULL,
        quantite INTEGER DEFAULT 0,
        dateAchat TEXT,
        fournisseur TEXT,
        notes TEXT
      )
    ''');

    // Magnetic Cylinders
    await db.execute('''
      CREATE TABLE magnetic_cylinders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        repeatId INTEGER NOT NULL,
        reference TEXT NOT NULL,
        quantite INTEGER DEFAULT 1,
        dateAchat TEXT,
        etat TEXT,
        notes TEXT,
        FOREIGN KEY(repeatId) REFERENCES repeats(id) ON DELETE CASCADE
      )
    ''');

    // Machine-Repeats Link (Many-to-Many)
    await db.execute('''
      CREATE TABLE machine_repeats_link(
        repeatId INTEGER NOT NULL,
        machineId INTEGER NOT NULL,
        PRIMARY KEY (repeatId, machineId),
        FOREIGN KEY(repeatId) REFERENCES repeats(id) ON DELETE CASCADE,
        FOREIGN KEY(machineId) REFERENCES machines(id) ON DELETE CASCADE
      )
    ''');

    // Trash Bin (Soft Delete)
    await db.execute('''
      CREATE TABLE trash_bin(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityType TEXT NOT NULL,
        entityId INTEGER NOT NULL,
        entityData TEXT NOT NULL,
        deletedAt TEXT NOT NULL,
        deletedBy TEXT
      )
    ''');

    // Machine Types
    await db.execute('''
      CREATE TABLE machine_types(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Seed Machine Types
    await db.insert('machine_types',
        {'name': 'Impression', 'description': 'Machines d\'impression'});
    await db.insert('machine_types',
        {'name': 'Découpe', 'description': 'Machines de découpe'});
    await db.insert('machine_types',
        {'name': 'Façonnage', 'description': 'Machines de façonnage'});

    // Machine Repeats (Old system for Article Form)
    await db.execute('''
      CREATE TABLE machine_repeats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        machine_name TEXT,
        repeat_value REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations if needed
    if (oldVersion < 6) {
      // For development simplicity, we might just want to ensure tables exist
      // In production, use ALTER TABLE
      // Here we assume tables might be missing if upgrading from v3

      // Create machines if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS machines(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          reference TEXT NOT NULL,
          typeId INTEGER NOT NULL,
          laize REAL,
          develop_min REAL,
          develop_max REAL,
          vitesse INTEGER,
          cout_horaire REAL,
          description TEXT
        )
      ''');

      // Create repeats if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS repeats(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          reference TEXT NOT NULL,
          nbrDents INTEGER NOT NULL,
          quantite INTEGER DEFAULT 0,
          dateAchat TEXT,
          fournisseur TEXT,
          notes TEXT
        )
      ''');

      // Create magnetic_cylinders if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS magnetic_cylinders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          repeatId INTEGER NOT NULL,
          reference TEXT NOT NULL,
          quantite INTEGER DEFAULT 1,
          dateAchat TEXT,
          etat TEXT,
          notes TEXT,
          FOREIGN KEY(repeatId) REFERENCES repeats(id) ON DELETE CASCADE
        )
      ''');

      // Create machine_repeats_link if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS machine_repeats_link(
          repeatId INTEGER NOT NULL,
          machineId INTEGER NOT NULL,
          PRIMARY KEY (repeatId, machineId),
          FOREIGN KEY(repeatId) REFERENCES repeats(id) ON DELETE CASCADE,
          FOREIGN KEY(machineId) REFERENCES machines(id) ON DELETE CASCADE
        )
      ''');

      // Create trash_bin if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS trash_bin(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          entityType TEXT NOT NULL,
          entityId INTEGER NOT NULL,
          entityData TEXT NOT NULL,
          deletedAt TEXT NOT NULL,
          deletedBy TEXT
        )
      ''');

      // Create machine_types if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS machine_types(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT
        )
      ''');

      // Seed if empty
      final typesCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM machine_types'));
      if (typesCount == 0) {
        await db.insert('machine_types',
            {'name': 'Impression', 'description': 'Machines d\'impression'});
        await db.insert('machine_types',
            {'name': 'Découpe', 'description': 'Machines de découpe'});
        await db.insert('machine_types',
            {'name': 'Façonnage', 'description': 'Machines de façonnage'});
      }

      // Create machine_repeats if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS machine_repeats(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          machine_name TEXT,
          repeat_value REAL
        )
      ''');
    }
  }

  // ==========================================
  // CRUD OPERATIONS
  // ==========================================

  // --- CLIENTS ---
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
      // Soft delete logic can be added here if needed, for now hard delete
      return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur suppression client: $e');
      rethrow;
    }
  }

  // --- SUPPORTS ---
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

  // --- ARTICLES ---
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

  Future<int> updateArticle(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      int id = row['id'];
      return await db.update('articles', row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur mise à jour article: $e');
      rethrow;
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

  Future<int> countArticlesByClient(int clientId) async {
    try {
      Database db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM articles WHERE clientId = ?',
        [clientId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('❌ Erreur comptage articles: $e');
      return 0;
    }
  }

  // --- PRICE HISTORY ---
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

  // --- MACHINES ---
  Future<int> insertMachine(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert('machines', row);
    } catch (e) {
      print('❌ Erreur insertion machine: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMachines() async {
    try {
      Database db = await database;
      return await db.query('machines', orderBy: 'reference');
    } catch (e) {
      print('❌ Erreur récupération machines: $e');
      return [];
    }
  }

  Future<int> updateMachine(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      int id = row['id'];
      return await db.update('machines', row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur mise à jour machine: $e');
      rethrow;
    }
  }

  Future<int> deleteMachine(int id) async {
    try {
      Database db = await database;
      return await db.delete('machines', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur suppression machine: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMachineTypes() async {
    try {
      Database db = await database;
      return await db.query('machine_types');
    } catch (e) {
      print('❌ Erreur récupération types machines: $e');
      return [];
    }
  }

  // --- MACHINE REPEATS (Old System) ---
  Future<int> insertMachineRepeat(
      String machineName, double repeatValue) async {
    try {
      Database db = await database;
      return await db.insert('machine_repeats', {
        'machine_name': machineName,
        'repeat_value': repeatValue,
      });
    } catch (e) {
      print('❌ Erreur insertion repeat machine: $e');
      rethrow;
    }
  }

  Future<List<double>> getRepeatsForMachine(String machineName) async {
    try {
      Database db = await database;
      final result = await db.query('machine_repeats',
          where: 'machine_name = ?',
          whereArgs: [machineName],
          orderBy: 'repeat_value ASC');
      return result.map((e) => (e['repeat_value'] as num).toDouble()).toList();
    } catch (e) {
      print('❌ Erreur récupération repeats machine: $e');
      return [];
    }
  }

  // --- REPEATS ---
  Future<int> insertRepeat(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      final id = await db.insert('repeats', row);
      print('✅ Repeat inséré avec ID: $id');
      return id;
    } catch (e) {
      print('❌ Erreur insertion repeat: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRepeats() async {
    try {
      Database db = await database;
      // Join with magnetic_cylinders to check if has any
      return await db.rawQuery('''
        SELECT r.*, 
               CASE WHEN COUNT(mc.id) > 0 THEN 1 ELSE 0 END as hasMagneticCylinder,
               GROUP_CONCAT(DISTINCT m.reference) as compatibleMachines
        FROM repeats r
        LEFT JOIN magnetic_cylinders mc ON r.id = mc.repeatId
        LEFT JOIN machine_repeats_link mrl ON r.id = mrl.repeatId
        LEFT JOIN machines m ON mrl.machineId = m.id
        GROUP BY r.id
        ORDER BY r.reference
      ''');
    } catch (e) {
      print('❌ Erreur récupération repeats: $e');
      return [];
    }
  }

  Future<int> updateRepeat(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      int id = row['id'];
      final result =
          await db.update('repeats', row, where: 'id = ?', whereArgs: [id]);
      print('✅ Repeat $id mis à jour');
      return result;
    } catch (e) {
      print('❌ Erreur mise à jour repeat: $e');
      rethrow;
    }
  }

  Future<int> deleteRepeat(int id) async {
    try {
      Database db = await database;
      return await db.delete('repeats', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur suppression repeat: $e');
      rethrow;
    }
  }

  // --- MAGNETIC CYLINDERS ---
  Future<int> insertMagneticCylinder(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert('magnetic_cylinders', row);
    } catch (e) {
      print('❌ Erreur insertion cylindre: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMagneticCylindersByRepeat(
      int repeatId) async {
    try {
      Database db = await database;
      return await db.query('magnetic_cylinders',
          where: 'repeatId = ?', whereArgs: [repeatId], orderBy: 'reference');
    } catch (e) {
      print('❌ Erreur récupération cylindres: $e');
      return [];
    }
  }

  Future<int> updateMagneticCylinder(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      int id = row['id'];
      return await db
          .update('magnetic_cylinders', row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur mise à jour cylindre: $e');
      rethrow;
    }
  }

  Future<int> deleteMagneticCylinder(int id) async {
    try {
      Database db = await database;
      return await db
          .delete('magnetic_cylinders', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Erreur suppression cylindre: $e');
      rethrow;
    }
  }

  // --- MACHINE LINKS ---
  Future<void> linkMachinesToRepeat(int repeatId, List<int> machineIds) async {
    try {
      Database db = await database;
      await db.transaction((txn) async {
        // Delete existing links
        await txn.delete(
          'machine_repeats_link',
          where: 'repeatId = ?',
          whereArgs: [repeatId],
        );

        // Insert new links
        for (var machineId in machineIds) {
          await txn.insert(
            'machine_repeats_link',
            {'machineId': machineId, 'repeatId': repeatId},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      });
      print('✅ Machines liées au repeat $repeatId');
    } catch (e) {
      print('❌ Erreur liaison machines: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMachinesByRepeat(int repeatId) async {
    try {
      Database db = await database;
      return await db.rawQuery('''
        SELECT m.*
        FROM machines m
        INNER JOIN machine_repeats_link mrl ON m.id = mrl.machineId
        WHERE mrl.repeatId = ?
      ''', [repeatId]);
    } catch (e) {
      print('❌ Erreur récupération machines liées: $e');
      return [];
    }
  }

  // --- TRASH / SOFT DELETE ---
  Future<int> softDelete(
      String entityType, int entityId, Map<String, dynamic> data) async {
    try {
      Database db = await database;
      return await db.insert('trash_bin', {
        'entityType': entityType,
        'entityId': entityId,
        'entityData': jsonEncode(data),
        'deletedAt': DateTime.now().toIso8601String(),
        'deletedBy': 'user', // Placeholder
      });
    } catch (e) {
      print('❌ Erreur soft delete: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTrashItems() async {
    try {
      Database db = await database;
      return await db.query('trash_bin', orderBy: 'deletedAt DESC');
    } catch (e) {
      print('❌ Erreur récupération corbeille: $e');
      return [];
    }
  }

  Future<int> restoreFromTrash(int trashId) async {
    try {
      Database db = await database;
      final trashItem =
          await db.query('trash_bin', where: 'id = ?', whereArgs: [trashId]);
      if (trashItem.isEmpty) return 0;

      final item = trashItem.first;
      final table = _getTableName(item['entityType'] as String);
      final data =
          jsonDecode(item['entityData'] as String) as Map<String, dynamic>;

      await db.insert(table, data,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return await db
          .delete('trash_bin', where: 'id = ?', whereArgs: [trashId]);
    } catch (e) {
      print('❌ Erreur restauration: $e');
      rethrow;
    }
  }

  Future<int> emptyTrash() async {
    try {
      Database db = await database;
      return await db.delete('trash_bin');
    } catch (e) {
      print('❌ Erreur vidage corbeille: $e');
      rethrow;
    }
  }

  String _getTableName(String entityType) {
    switch (entityType) {
      case 'client':
        return 'clients';
      case 'article':
        return 'articles';
      case 'machine':
        return 'machines';
      case 'repeat':
        return 'repeats';
      case 'support':
        return 'supports';
      default:
        throw Exception('Unknown entity type: $entityType');
    }
  }
}
