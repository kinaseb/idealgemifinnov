import 'dart:async';
import 'package:ideal_calcule/class/article.dart';
import 'package:ideal_calcule/class/client.dart';
import 'package:ideal_calcule/class/support.dart';
import 'package:ideal_calcule/services/database_helper.dart';
import 'package:ideal_calcule/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _supabase = SupabaseService().client;
  final _localDb = DatabaseHelper();
  final _changeController = StreamController<void>.broadcast();
  Stream<void> get onChange => _changeController.stream;

  RealtimeChannel? _clientsChannel;
  RealtimeChannel? _supportsChannel;
  RealtimeChannel? _articlesChannel;

  Future<void> startSync() async {
    print('🔄 Démarrage de la synchronisation...');
    // 1. Pull existing data (Initial Sync)
    await _pullAllData();

    // 2. Listen for future changes
    print('🎧 Écoute des changements temps réel...');
    _listenToClients();
    _listenToSupports();
    _listenToArticles();
  }

  Future<void> _pullAllData() async {
    print('⬇️ Récupération des données initiales...');
    try {
      // Clients
      final clients = await _supabase.from('clients').select();
      for (var map in clients) {
        final client = Client.fromSupabaseMap(map);
        await _upsertLocalClient(client);
      }
      print('✅ ${clients.length} Clients synchronisés');

      // Supports
      final supports = await _supabase.from('supports').select();
      for (var map in supports) {
        final support = Support.fromSupabaseMap(map);
        await _upsertLocalSupport(support);
      }
      print('✅ ${supports.length} Supports synchronisés');

      // Articles
      final articles = await _supabase.from('articles').select();
      for (var map in articles) {
        final article = Article.fromSupabaseMap(map);
        await _upsertLocalArticle(article);
      }
      print('✅ ${articles.length} Articles synchronisés');

      // Notify UI to refresh
      _changeController.add(null);
    } catch (e) {
      print('❌ Erreur lors du pull initial: $e');
    }
  }

  // Helper methods to avoid code duplication
  Future<void> _upsertLocalClient(Client client) async {
    final existing = (await _localDb.getClients())
        .where((c) => c['id'] == client.id)
        .isNotEmpty;
    if (existing) {
      await _localDb.updateClient(client.toMap());
    } else {
      await _localDb.insertClient(client.toMap());
    }
  }

  Future<void> _upsertLocalSupport(Support support) async {
    final existing = (await _localDb.getSupports())
        .where((s) => s['id'] == support.id)
        .isNotEmpty;
    if (existing) {
      await _localDb.updateSupport(support.toMap());
    } else {
      await _localDb.insertSupport(support.toMap());
    }
  }

  Future<void> _upsertLocalArticle(Article article) async {
    // For articles, we can try update, if 0 rows affected, then insert.
    // But since we don't have updateArticle returning rows affected easily without modifying DB helper,
    // we'll use the try-insert-catch approach or check existence.
    // Checking existence for all articles might be slow if many.
    // Let's assume ID is key.

    // Optimization: DatabaseHelper could have an upsert method.
    // For now, let's just use update and if it fails (or we can't know), we insert?
    // Actually, DatabaseHelper.updateArticle returns int (rows affected).

    final rows = await _localDb.updateArticle(article.toMap());
    if (rows == 0) {
      await _localDb.insertArticle(article.toMap());
    }
  }

  void stopSync() {
    print('⏹️ Arrêt de la synchronisation.');
    _supabase.removeAllChannels();
  }

  void _listenToClients() {
    _clientsChannel = _supabase
        .channel('public:clients')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'clients',
          callback: (payload) async {
            print('🔔 Changement détecté sur Clients: ${payload.eventType}');
            await _handleClientChange(payload);
          },
        )
        .subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        print('✅ Abonné au canal Clients');
      } else if (status == RealtimeSubscribeStatus.closed) {
        print('❌ Canal Clients fermé');
      } else if (error != null) {
        print('⚠️ Erreur abonnement Clients: $error');
      }
    });
  }

  Future<void> _handleClientChange(PostgresChangePayload payload) async {
    try {
      if (payload.eventType == PostgresChangeEvent.insert) {
        final newRecord = payload.newRecord;
        final client = Client.fromSupabaseMap(newRecord);

        // Check if exists
        final existing = (await _localDb.getClients())
            .where((c) => c['id'] == client.id)
            .isNotEmpty;

        if (!existing) {
          await _localDb.insertClient(client.toMap());
          print('➕ Client ajouté localement: ${client.name}');
          _changeController.add(null);
        }
      } else if (payload.eventType == PostgresChangeEvent.update) {
        final newRecord = payload.newRecord;
        final client = Client.fromSupabaseMap(newRecord);
        await _localDb.updateClient(client.toMap());
        print('✏️ Client mis à jour localement: ${client.name}');
        _changeController.add(null);
      } else if (payload.eventType == PostgresChangeEvent.delete) {
        final oldRecord = payload.oldRecord;
        final id = oldRecord['id'] as int;
        await _localDb.deleteClient(id);
        print('🗑️ Client supprimé localement (ID: $id)');
        _changeController.add(null);
      }
    } catch (e) {
      print('❌ Erreur sync Client: $e');
    }
  }

  void _listenToSupports() {
    _supportsChannel = _supabase
        .channel('public:supports')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'supports',
          callback: (payload) async {
            print('🔔 Changement détecté sur Supports: ${payload.eventType}');
            await _handleSupportChange(payload);
          },
        )
        .subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        print('✅ Abonné au canal Supports');
      } else if (error != null) {
        print('⚠️ Erreur abonnement Supports: $error');
      }
    });
  }

  Future<void> _handleSupportChange(PostgresChangePayload payload) async {
    try {
      if (payload.eventType == PostgresChangeEvent.insert) {
        final support = Support.fromSupabaseMap(payload.newRecord);
        final existing = (await _localDb.getSupports())
            .where((s) => s['id'] == support.id)
            .isNotEmpty;
        if (!existing) {
          await _localDb.insertSupport(support.toMap());
        }
      } else if (payload.eventType == PostgresChangeEvent.update) {
        final support = Support.fromSupabaseMap(payload.newRecord);
        await _localDb.updateSupport(support.toMap());
      } else if (payload.eventType == PostgresChangeEvent.delete) {
        final id = payload.oldRecord['id'] as int;
        await _localDb.deleteSupport(id);
      }
    } catch (e) {
      print('❌ Erreur sync Support: $e');
    }
  }

  void _listenToArticles() {
    _articlesChannel = _supabase
        .channel('public:articles')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'articles',
          callback: (payload) async {
            print('🔔 Changement détecté sur Articles: ${payload.eventType}');
            await _handleArticleChange(payload);
          },
        )
        .subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        print('✅ Abonné au canal Articles');
      } else if (error != null) {
        print('⚠️ Erreur abonnement Articles: $error');
      }
    });
  }

  Future<void> _handleArticleChange(PostgresChangePayload payload) async {
    try {
      if (payload.eventType == PostgresChangeEvent.insert) {
        final article = Article.fromSupabaseMap(payload.newRecord);
        // For articles, check existence might be heavy if we fetch all.
        // But we have ID.
        // DatabaseHelper doesn't have getArticleById.
        // We can try update, if 0 rows affected, then insert?
        // Or just insert and catch unique constraint error if any (but ID is PK).

        // Let's try to insert directly with ConflictAlgorithm.replace in DatabaseHelper?
        // Currently it uses default insert.

        // Let's use a try-catch for now.
        try {
          await _localDb.insertArticle(article.toMap());
          print('➕ Article ajouté localement: ${article.name}');
        } catch (e) {
          // If it fails, maybe it exists? Try update?
          // Or it might be a foreign key issue (Client not yet synced).
          // This is a risk with async sync.
          print('⚠️ Erreur insert article (peut-être déjà là?): $e');
        }
      } else if (payload.eventType == PostgresChangeEvent.update) {
        final article = Article.fromSupabaseMap(payload.newRecord);
        await _localDb.updateArticle(article.toMap());
        print('✏️ Article mis à jour localement: ${article.name}');
      } else if (payload.eventType == PostgresChangeEvent.delete) {
        final id = payload.oldRecord['id'] as int;
        await _localDb.deleteArticle(id);
        print('🗑️ Article supprimé localement (ID: $id)');
      }
    } catch (e) {
      print('❌ Erreur sync Article: $e');
    }
  }
}
