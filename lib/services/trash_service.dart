import 'dart:convert';
import 'database_helper.dart';

class TrashService {
  static final TrashService _instance = TrashService._internal();
  factory TrashService() => _instance;
  TrashService._internal();

  // Soft delete - Move to trash
  Future<void> moveToTrash({
    required String entityType,
    required int entityId,
    required Map<String, dynamic> entityData,
    Map<String, dynamic>? relatedData,
  }) async {
    try {
      final db = await DatabaseHelper().database;

      // Save to trash_bin
      await db.insert('trash_bin', {
        'entityType': entityType,
        'entityId': entityId,
        'entityData': jsonEncode(entityData),
        'deletedAt': DateTime.now().toIso8601String(),
        'relatedData': relatedData != null ? jsonEncode(relatedData) : null,
      });

      // Mark as deleted (soft delete)
      await db.update(
        '${entityType}s', // clients, articles, etc.
        {'deletedAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [entityId],
      );

      print('✅ $entityType $entityId moved to trash');
    } catch (e) {
      print('❌ Error moving to trash: $e');
      rethrow;
    }
  }

  // Get all trash items
  Future<List<Map<String, dynamic>>> getTrashItems() async {
    try {
      final db = await DatabaseHelper().database;
      return await db.query(
        'trash_bin',
        orderBy: 'deletedAt DESC',
      );
    } catch (e) {
      print('❌ Error getting trash items: $e');
      return [];
    }
  }

  // Get trash items by type
  Future<List<Map<String, dynamic>>> getTrashItemsByType(String type) async {
    try {
      final db = await DatabaseHelper().database;
      return await db.query(
        'trash_bin',
        where: 'entityType = ?',
        whereArgs: [type],
        orderBy: 'deletedAt DESC',
      );
    } catch (e) {
      print('❌ Error getting trash items by type: $e');
      return [];
    }
  }

  // Restore from trash
  Future<void> restore(int trashId) async {
    try {
      final db = await DatabaseHelper().database;

      // Get trash item
      final trashItems = await db.query(
        'trash_bin',
        where: 'id = ?',
        whereArgs: [trashId],
      );

      if (trashItems.isEmpty) {
        throw Exception('Trash item not found');
      }

      final trashItem = trashItems.first;
      final entityType = trashItem['entityType'] as String;
      final entityId = trashItem['entityId'] as int;

      // Restore deletedAt = null
      await db.update(
        '${entityType}s',
        {'deletedAt': null},
        where: 'id = ?',
        whereArgs: [entityId],
      );

      // Remove from trash
      await db.delete(
        'trash_bin',
        where: 'id = ?',
        whereArgs: [trashId],
      );

      print('✅ $entityType $entityId restored');
    } catch (e) {
      print('❌ Error restoring: $e');
      rethrow;
    }
  }

  // Permanent delete
  Future<void> permanentDelete(int trashId) async {
    try {
      final db = await DatabaseHelper().database;

      // Get trash item
      final trashItems = await db.query(
        'trash_bin',
        where: 'id = ?',
        whereArgs: [trashId],
      );

      if (trashItems.isEmpty) {
        throw Exception('Trash item not found');
      }

      final trashItem = trashItems.first;
      final entityType = trashItem['entityType'] as String;
      final entityId = trashItem['entityId'] as int;

      // Permanently delete from main table
      await db.delete(
        '${entityType}s',
        where: 'id = ?',
        whereArgs: [entityId],
      );

      // Remove from trash
      await db.delete(
        'trash_bin',
        where: 'id = ?',
        whereArgs: [trashId],
      );

      print('✅ $entityType $entityId permanently deleted');
    } catch (e) {
      print('❌ Error permanent delete: $e');
      rethrow;
    }
  }

  // Empty entire trash
  Future<void> emptyTrash() async {
    try {
      final db = await DatabaseHelper().database;

      // Get all trash items
      final trashItems = await db.query('trash_bin');

      await db.transaction((txn) async {
        for (var item in trashItems) {
          final entityType = item['entityType'] as String;
          final entityId = item['entityId'] as int;

          // Permanently delete from main table
          await txn.delete(
            '${entityType}s',
            where: 'id = ?',
            whereArgs: [entityId],
          );
        }

        // Clear trash bin
        await txn.delete('trash_bin');
      });

      print('✅ Trash emptied');
    } catch (e) {
      print('❌ Error emptying trash: $e');
      rethrow;
    }
  }
}
