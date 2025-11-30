import 'package:ideal_calcule/class/article.dart';
import 'package:ideal_calcule/class/client.dart';
import 'package:ideal_calcule/class/support.dart';
import 'package:ideal_calcule/services/database_helper.dart';
import 'package:ideal_calcule/services/supabase_service.dart';

class DataMigrationService {
  final DatabaseHelper _localDb = DatabaseHelper();
  final SupabaseService _supabase = SupabaseService();

  Future<void> migrateAllData() async {
    print('🚀 Démarrage de la migration des données...');

    try {
      await _migrateClients();
      await _migrateSupports();
      await _migrateArticles();
      print('✅ Migration terminée avec succès !');
    } catch (e) {
      print('❌ Erreur générale de migration: $e');
    }
  }

  Future<void> _migrateClients() async {
    print('... Migration des Clients');
    final clientsData = await _localDb.getClients();
    final clients = clientsData.map((e) => Client.fromMap(e)).toList();

    if (clients.isEmpty) {
      print('Aucun client à migrer.');
      return;
    }

    for (var client in clients) {
      try {
        // Check if exists (by ID) to avoid duplicates if run multiple times
        final exists = await _supabase.client
            .from('clients')
            .select()
            .eq('id', client.id!)
            .maybeSingle();

        if (exists == null) {
          // We explicitly send the ID to preserve relationships
          final data = client.toSupabaseMap();
          data['id'] = client.id;

          await _supabase.client.from('clients').insert(data);
          print('Client migré: ${client.name} (ID: ${client.id})');
        } else {
          print('Client déjà existant: ${client.name} (ID: ${client.id})');
        }
      } catch (e) {
        print('Erreur migration client ${client.name}: $e');
      }
    }
  }

  Future<void> _migrateSupports() async {
    print('... Migration des Supports');
    final supportsData = await _localDb.getSupports();
    final supports = supportsData.map((e) => Support.fromMap(e)).toList();

    if (supports.isEmpty) {
      print('Aucun support à migrer.');
      return;
    }

    for (var support in supports) {
      try {
        final exists = await _supabase.client
            .from('supports')
            .select()
            .eq('id', support.id!)
            .maybeSingle();

        if (exists == null) {
          final data = support.toSupabaseMap();
          data['id'] = support.id;

          await _supabase.client.from('supports').insert(data);
          print('Support migré: ${support.name} (ID: ${support.id})');
        } else {
          print('Support déjà existant: ${support.name} (ID: ${support.id})');
        }
      } catch (e) {
        print('Erreur migration support ${support.name}: $e');
      }
    }
  }

  Future<void> _migrateArticles() async {
    print('... Migration des Articles');
    // We need to get all articles. DatabaseHelper has getArticlesByClient,
    // but we might need a method to get ALL articles or iterate through clients.
    // Let's iterate through clients since we just migrated them.

    final clientsData = await _localDb.getClients();

    for (var clientData in clientsData) {
      final clientId = clientData['id'] as int;
      final articlesData = await _localDb.getArticlesByClient(clientId);
      final articles = articlesData.map((e) => Article.fromMap(e)).toList();

      for (var article in articles) {
        try {
          final exists = await _supabase.client
              .from('articles')
              .select()
              .eq('id', article.id!)
              .maybeSingle();

          if (exists == null) {
            final data = article.toSupabaseMap();
            data['id'] = article.id;

            await _supabase.client.from('articles').insert(data);
            print('Article migré: ${article.name} (ID: ${article.id})');
          } else {
            print('Article déjà existant: ${article.name} (ID: ${article.id})');
          }
        } catch (e) {
          print('Erreur migration article ${article.name}: $e');
        }
      }
    }
  }
}
