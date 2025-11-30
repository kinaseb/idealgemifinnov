import 'dart:async';
import 'package:flutter/material.dart';
import '../class/support.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import '../services/supabase_service.dart';
import 'support_history_page.dart';

class SupportsPage extends StatefulWidget {
  const SupportsPage({super.key});

  @override
  State<SupportsPage> createState() => _SupportsPageState();
}

class _SupportsPageState extends State<SupportsPage> {
  late Future<List<Support>> _supportsFuture;

  StreamSubscription? _syncSubscription;

  @override
  void initState() {
    super.initState();
    _refreshSupports();

    // Listen for realtime updates
    _syncSubscription = SyncService().onChange.listen((_) {
      if (mounted) {
        _refreshSupports();
      }
    });
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  void _refreshSupports() {
    setState(() {
      _supportsFuture = DatabaseHelper().getSupports().then((data) {
        return data.map((e) => Support.fromMap(e)).toList();
      });
    });
  }

  void _addOrEditSupport({Support? support}) {
    final nameController = TextEditingController(text: support?.name ?? '');
    final priceController =
        TextEditingController(text: support?.currentPrice.toString() ?? '');
    final supplierController =
        TextEditingController(text: support?.supplier ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            support == null ? 'Ajouter un support' : 'Modifier un support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom du support'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Prix actuel'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: supplierController,
              decoration: const InputDecoration(labelText: 'Fournisseur'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validation
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un nom de support'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              if (priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un prix'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final price = double.tryParse(priceController.text);
              if (price == null || price < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un prix valide'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Close the dialog first
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                if (support == null) {
                  // Add new
                  final newSupport = Support(
                    name: nameController.text,
                    currentPrice: price,
                    supplier: supplierController.text.isEmpty
                        ? null
                        : supplierController.text,
                  );

                  final supportData = newSupport.toSupabaseMap();
                  supportData.remove('id');
                  await SupabaseService().insertSupport(supportData);

                  // Note: History is not yet synced to Supabase in this version.
                  // Ideally, we should also push history to a 'price_history' table in Supabase.
                  // For now, we only sync the main support item.

                  if (mounted) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Support ajouté avec succès!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  // Update existing
                  final updatedSupport = Support(
                    id: support.id,
                    name: nameController.text,
                    currentPrice: price,
                    supplier: supplierController.text.isEmpty
                        ? null
                        : supplierController.text,
                  );

                  await SupabaseService().updateSupport(
                      support.id!, updatedSupport.toSupabaseMap());

                  if (mounted) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Support modifié avec succès!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }

                _refreshSupports();
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Erreur lors de la sauvegarde du support: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supports (Matière Première)'),
      ),
      body: FutureBuilder<List<Support>>(
        future: _supportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun support trouvé.'));
          }

          final supports = snapshot.data!;
          return ListView.builder(
            itemCount: supports.length,
            itemBuilder: (context, index) {
              final support = supports[index];
              return Card(
                child: ListTile(
                  title: Text(support.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Prix actuel: ${support.currentPrice.toStringAsFixed(2)} DA | Fournisseur: ${support.supplier ?? "N/A"}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SupportHistoryPage(support: support),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrEditSupport(support: support),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await SupabaseService().deleteSupport(support.id!);
                          _refreshSupports();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditSupport(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
