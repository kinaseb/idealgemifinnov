import 'package:flutter/material.dart';
import '../../class/stock_plate.dart';
import '../../services/supabase_service.dart';

class StockPlatePage extends StatefulWidget {
  const StockPlatePage({super.key});

  @override
  State<StockPlatePage> createState() => _StockPlatePageState();
}

class _StockPlatePageState extends State<StockPlatePage> {
  late Future<List<StockPlate>> _stocksFuture;

  @override
  void initState() {
    super.initState();
    _refreshStocks();
  }

  void _refreshStocks() {
    setState(() {
      _stocksFuture = SupabaseService().getStocksPlate().then((data) {
        return data.map((e) => StockPlate.fromMap(e)).toList();
      });
    });
  }

  void _addOrEditStock({StockPlate? stock}) {
    // Note: Linking to Clients/Articles is complex in a simple dialog.
    // For MVP, we will just allow editing text fields or simple IDs if necessary.
    // A proper implementation would require dropdowns for Clients and Articles.
    // For now, let's keep it simple with Type, Location, Status.

    final typeController = TextEditingController(text: stock?.type ?? '');
    final locationController =
        TextEditingController(text: stock?.location ?? '');
    String status = stock?.status ?? 'Good';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stock == null ? 'Ajouter Cliché' : 'Modifier Cliché'),
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: typeController,
                  decoration:
                      const InputDecoration(labelText: 'Type (ex: 1.14mm)'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Emplacement'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  items: ['Good', 'Worn', 'Damaged']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => status = val!),
                  decoration: const InputDecoration(labelText: 'État'),
                ),
                const SizedBox(height: 10),
                const Text(
                    'Note: Pour lier à un Client/Article, utilisez la page Article.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'type': typeController.text,
                'location': locationController.text,
                'status': status,
                // client_id and article_id would be handled here in a full version
              };

              try {
                if (stock == null) {
                  await SupabaseService().insertStockPlate(data);
                } else {
                  await SupabaseService().updateStockPlate(stock.id!, data);
                }
                if (mounted) Navigator.pop(context);
                _refreshStocks();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Clichés')),
      body: FutureBuilder<List<StockPlate>>(
        future: _stocksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun stock cliché.'));
          }

          final stocks = snapshot.data!;
          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.layers),
                  title: Text(
                      '${stock.clientName ?? "Client?"} - ${stock.articleName ?? "Article?"}'),
                  subtitle: Text(
                      'Type: ${stock.type} | Loc: ${stock.location} | Status: ${stock.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrEditStock(stock: stock),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await SupabaseService().deleteStockPlate(stock.id!);
                          _refreshStocks();
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
        onPressed: () => _addOrEditStock(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
