import 'package:flutter/material.dart';
import '../../class/stock_support.dart';
import '../../class/support.dart';
import '../../services/supabase_service.dart';
import '../../services/database_helper.dart'; // For getting supports list

class StockSupportPage extends StatefulWidget {
  const StockSupportPage({super.key});

  @override
  State<StockSupportPage> createState() => _StockSupportPageState();
}

class _StockSupportPageState extends State<StockSupportPage> {
  late Future<List<StockSupport>> _stocksFuture;
  List<Support> _availableSupports = [];

  @override
  void initState() {
    super.initState();
    _loadSupports();
    _refreshStocks();
  }

  Future<void> _loadSupports() async {
    // We can get supports from local DB or Supabase.
    // Since we are in "Cloud First" mode for stocks, let's fetch from Supabase via DatabaseHelper (which is now hybrid)
    // or directly via SupabaseService if we added a method.
    // DatabaseHelper.getSupports() returns local data, but SyncService keeps it updated.
    // Let's use DatabaseHelper for now as it returns List<Map>.
    final data = await DatabaseHelper().getSupports();
    setState(() {
      _availableSupports = data.map((e) => Support.fromMap(e)).toList();
    });
  }

  void _refreshStocks() {
    SupabaseService().getStocksSupport().then((data) {
      if (!mounted) return;
      setState(() {
        _stocksFuture =
            Future.value(data.map((e) => StockSupport.fromMap(e)).toList());
      });
    });
  }

  void _addOrEditStock({StockSupport? stock}) {
    int? selectedSupportId = stock?.supportId;
    final laizeController =
        TextEditingController(text: stock?.laize.toString() ?? '');
    final longueurController =
        TextEditingController(text: stock?.longueur.toString() ?? '');
    final micronageController =
        TextEditingController(text: stock?.micronage?.toString() ?? '');
    final quantityController =
        TextEditingController(text: stock?.quantity.toString() ?? '0');
    final locationController =
        TextEditingController(text: stock?.location ?? '');

    showDialog(
      context: context,
      builder: (parentContext) =>
          StatefulBuilder(builder: (dialogContext, setState) {
        return AlertDialog(
          title:
              Text(stock == null ? 'Ajouter Stock Support' : 'Modifier Stock'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedSupportId,
                  items: _availableSupports.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
                    );
                  }).toList(),
                  onChanged: stock ==
                          null // Only allow changing support on creation? Or allow edit?
                      ? (val) => setState(() => selectedSupportId = val)
                      : null, // Lock support on edit to avoid confusion or handle complex migration
                  decoration: const InputDecoration(labelText: 'Support'),
                ),
                TextField(
                  controller: laizeController,
                  decoration: const InputDecoration(labelText: 'Laize (mm)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: longueurController,
                  decoration: const InputDecoration(labelText: 'Longueur (m)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: micronageController,
                  decoration: const InputDecoration(labelText: 'Micronage'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: quantityController,
                  decoration:
                      const InputDecoration(labelText: 'Quantité (Rouleaux)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Emplacement'),
                ),
                if (stock != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Note: Modifier la quantité ici créera une entrée "Ajustement" dans l\'historique.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedSupportId == null ||
                    laizeController.text.isEmpty ||
                    longueurController.text.isEmpty) {
                  return;
                }

                final quantity = int.tryParse(quantityController.text) ?? 0;

                final selectedSupport = _availableSupports.firstWhere(
                  (s) => s.id == selectedSupportId,
                  orElse: () => Support(
                      id: -1, name: 'Inconnu', currentPrice: 0, supplier: ''),
                );

                final data = {
                  'support_id': selectedSupportId,
                  'type': selectedSupport.name, // Satisfy NOT NULL constraint
                  'laize': int.tryParse(laizeController.text) ?? 0,
                  'longueur': int.tryParse(longueurController.text) ?? 0,
                  'micronage': int.tryParse(micronageController.text),
                  'quantity': quantity,
                  'location': locationController.text,
                };

                try {
                  if (stock == null) {
                    await SupabaseService().addStockSupport(data);
                  } else {
                    if (stock.id == null) {
                      throw "Stock ID is null";
                    }
                    // Calculate difference for history
                    final diff = quantity - stock.quantity;
                    await SupabaseService().updateStockSupport(
                        stock.id!, data, diff, 'Modification manuelle');
                  }
                  if (mounted) {
                    Navigator.pop(dialogContext);
                    _refreshStocks();
                  }
                } catch (e) {
                  debugPrint('Error saving stock: $e');
                  if (mounted) {
                    // Use parent context (this.context) for SnackBar, not dialogContext
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Erreur: $e')));
                  }
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Supports')),
      body: FutureBuilder<List<StockSupport>>(
        future: _stocksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun stock support.'));
          }

          final stocks = snapshot.data!;
          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(stock.quantity.toString()),
                  ),
                  title: Text(
                      '${stock.supportName ?? "Inconnu"} ${stock.micronage ?? "?"}µ'),
                  subtitle: Text(
                      '${stock.laize}mm x ${stock.longueur}m | Loc: ${stock.location ?? "N/A"}'),
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
                          await SupabaseService().deleteStockSupport(stock.id!);
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
