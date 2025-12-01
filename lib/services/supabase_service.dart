import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  // Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://hwydiboicuuvmwycfmra.supabase.co',
      anonKey: 'sb_publishable_if9lFXn_-RQBHSRuYAt7IQ_Lex6wKF1',
    );
  }

  SupabaseClient get client => Supabase.instance.client;

  Future<String?> uploadImage(File file, String bucketFolder) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        throw 'Utilisateur non connecté';
      }

      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final storagePath = '$bucketFolder/$fileName';

      print('📤 Uploading to $storagePath...');

      await client.storage.from('images').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = client.storage.from('images').getPublicUrl(storagePath);
      print('✅ Upload réussi: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Erreur upload image: $e');
      rethrow;
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await client.from('clients').select().limit(1);
      print('✅ Connection Supabase OK: $response');
      return true;
    } catch (e) {
      print('❌ Erreur Connection Supabase: $e');
      return false;
    }
  }

  // --- CRUD Clients ---
  Future<void> insertClient(Map<String, dynamic> data) async {
    await client.from('clients').insert(data);
  }

  Future<void> updateClient(int id, Map<String, dynamic> data) async {
    await client.from('clients').update(data).eq('id', id);
  }

  Future<void> deleteClient(int id) async {
    await client.from('clients').delete().eq('id', id);
  }

  // --- CRUD Supports ---
  Future<void> insertSupport(Map<String, dynamic> data) async {
    await client.from('supports').insert(data);
  }

  Future<void> updateSupport(int id, Map<String, dynamic> data) async {
    await client.from('supports').update(data).eq('id', id);
  }

  Future<void> deleteSupport(int id) async {
    await client.from('supports').delete().eq('id', id);
  }

  // --- CRUD Articles ---
  Future<void> insertArticle(Map<String, dynamic> data) async {
    await client.from('articles').insert(data);
  }

  Future<void> updateArticle(int id, Map<String, dynamic> data) async {
    await client.from('articles').update(data).eq('id', id);
  }

  Future<void> deleteArticle(int id) async {
    await client.from('articles').delete().eq('id', id);
  }

  // --- CRUD Stocks Support (Refactored) ---
  Future<List<Map<String, dynamic>>> getStocksSupport() async {
    return await client
        .from('stocks_supports')
        .select('*, supports(name)')
        .order('created_at');
  }

  Future<void> addStockSupport(Map<String, dynamic> data) async {
    print('➕ Adding Stock Support: $data');
    // 1. Check if same stock exists (support_id, laize, longueur, micronage)
    var query = client
        .from('stocks_supports')
        .select()
        .eq('support_id', data['support_id'])
        .eq('laize', data['laize'])
        .eq('longueur', data['longueur']);

    if (data['micronage'] != null) {
      query = query.eq('micronage', data['micronage']);
    } else {
      query = query.isFilter('micronage', null);
    }

    final existing = await query.maybeSingle();

    if (existing != null) {
      print('🔄 Stock exists, updating quantity...');
      // 2. Update quantity
      final currentQty = (existing['quantity'] as num?)?.toInt() ?? 0;
      final addQty = (data['quantity'] as num?)?.toInt() ?? 0;
      final newQuantity = currentQty + addQty;

      await client
          .from('stocks_supports')
          .update({'quantity': newQuantity}).eq('id', existing['id']);

      // 3. Log History
      await _logStockHistory(
          existing['id'], 'ADD', addQty, 'Ajout manuel (Agrégation)');
    } else {
      print('🆕 Creating new stock entry...');
      // 2. Insert new
      final response =
          await client.from('stocks_supports').insert(data).select().single();

      // 3. Log History
      final addQty = (data['quantity'] as num?)?.toInt() ?? 0;
      await _logStockHistory(
          response['id'], 'ADD', addQty, 'Ajout manuel (Nouveau)');
    }
  }

  Future<void> updateStockSupport(int id, Map<String, dynamic> data,
      int quantityChange, String reason) async {
    print('✏️ Updating Stock Support ID: $id with data: $data');
    await client.from('stocks_supports').update(data).eq('id', id);

    if (quantityChange != 0) {
      await _logStockHistory(id, quantityChange > 0 ? 'ADD' : 'REMOVE',
          quantityChange.abs(), reason);
    }
  }

  Future<void> _logStockHistory(
      int stockId, String type, int quantity, String reason) async {
    await client.from('stock_history').insert({
      'stock_id': stockId,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'user_id': client.auth.currentUser?.id,
    });
  }

  // --- Employees ---
  Future<List<Map<String, dynamic>>> getEmployees() async {
    return await client.from('employees').select().order('last_name');
  }

  Future<void> insertEmployee(Map<String, dynamic> data) async {
    await client.from('employees').insert(data);
  }

  Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
    await client.from('employees').update(data).eq('id', id);
  }

  Future<void> deleteEmployee(int id) async {
    await client.from('employees').delete().eq('id', id);
  }

  // --- Order History ---
  Future<void> logOrderMovement(
      int orderId, String fromStatus, String toStatus, int employeeId) async {
    await client.from('order_history').insert({
      'order_id': orderId,
      'from_status': fromStatus,
      'to_status': toStatus,
      'employee_id': employeeId,
    });
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(int orderId) async {
    return await client
        .from('order_history')
        .select('*, employees(*)')
        .eq('order_id', orderId)
        .order('timestamp', ascending: false);
  }

  Future<void> transferOrderHistory(int sourceId, int targetId) async {
    await client
        .from('order_history')
        .update({'order_id': targetId}).eq('order_id', sourceId);
  }

  Future<void> deleteStockSupport(int id) async {
    await client.from('stocks_supports').delete().eq('id', id);
  }

  Future<Map<String, dynamic>?> findStock(int supportId, int laize) async {
    final response = await client
        .from('stocks_supports')
        .select()
        .eq('support_id', supportId)
        .eq('laize', laize)
        .order('quantity', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }

  // --- CRUD Stocks Encre ---
  Future<List<Map<String, dynamic>>> getStocksInk() async {
    return await client.from('stocks_encre').select().order('created_at');
  }

  Future<void> insertStockInk(Map<String, dynamic> data) async {
    await client.from('stocks_encre').insert(data);
  }

  Future<void> updateStockInk(int id, Map<String, dynamic> data) async {
    await client.from('stocks_encre').update(data).eq('id', id);
  }

  Future<void> deleteStockInk(int id) async {
    await client.from('stocks_encre').delete().eq('id', id);
  }

  // --- CRUD Stocks Clichés ---
  Future<List<Map<String, dynamic>>> getStocksPlate() async {
    // Join with clients and articles to get names
    return await client
        .from('stocks_cliches')
        .select('*, clients(name), articles(name)')
        .order('created_at');
  }

  Future<void> insertStockPlate(Map<String, dynamic> data) async {
    await client.from('stocks_cliches').insert(data);
  }

  // --- CRUD Orders ---
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      return await client
          .from('orders')
          .select('*, clients(*), articles(*)')
          .order('date', ascending: false);
    } catch (e) {
      // Fallback: If joins fail (missing FKs), fetch raw orders
      // The UI handles missing client/article data gracefully
      return await client
          .from('orders')
          .select('*')
          .order('date', ascending: false);
    }
  }

  Future<int?> insertOrder(Map<String, dynamic> data) async {
    final response = await client.from('orders').insert(data).select().single();
    return response['id'] as int?;
  }

  Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    await client.from('orders').update(data).eq('id', id);
  }

  Future<void> deleteOrder(int id) async {
    await client.from('orders').delete().eq('id', id);
  }

  Future<void> updateStockPlate(int id, Map<String, dynamic> data) async {
    await client.from('stocks_cliches').update(data).eq('id', id);
  }

  Future<void> deleteStockPlate(int id) async {
    await client.from('stocks_cliches').delete().eq('id', id);
  }
}
