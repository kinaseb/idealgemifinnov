import 'package:flutter/material.dart';
import '../../class/stock_ink.dart';
import '../../services/supabase_service.dart';

class StockInkPage extends StatefulWidget {
  const StockInkPage({super.key});

  @override
  State<StockInkPage> createState() => _StockInkPageState();
}

class _StockInkPageState extends State<StockInkPage> {
  late Future<List<StockInk>> _stocksFuture;

  @override
  void initState() {
    super.initState();
    _refreshStocks();
  }

  void _refreshStocks() {
    setState(() {
      _stocksFuture = SupabaseService().getStocksInk().then((data) {
        return data.map((e) => StockInk.fromMap(e)).toList();
      });
    });
  }

  void _addOrEditStock({StockInk? stock}) {
    final colorController = TextEditingController(text: stock?.color ?? '');
    final typeController = TextEditingController(text: stock?.type ?? '');
    final quantityController =
        TextEditingController(text: stock?.quantityKg.toString() ?? '0');
    final supplierController =
        TextEditingController(text: stock?.supplier ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stock == null ? 'Ajouter Encre' : 'Modifier Encre'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                    labelText: 'Couleur (ex: Pantone 123C)'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type (ex: UV)'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantité (Kg)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: supplierController,
                decoration: const InputDecoration(labelText: 'Fournisseur'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (colorController.text.isEmpty) return;

              final data = {
                'color': colorController.text,
                'type': typeController.text,
                'quantity_kg': double.tryParse(quantityController.text) ?? 0.0,
                'supplier': supplierController.text,
              };

              try {
                if (stock == null) {
                  await SupabaseService().insertStockInk(data);
                } else {
                  await SupabaseService().updateStockInk(stock.id!, data);
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
      appBar: AppBar(title: const Text('Stock Encre')),
      body: FutureBuilder<List<StockInk>>(
        future: _stocksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun stock encre.'));
          }

          final stocks = snapshot.data!;
          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.primaries[
                        stock.color.length % Colors.primaries.length],
                    child: Text(stock.color.isNotEmpty ? stock.color[0] : '?'),
                  ),
                  title: Text('${stock.color} (${stock.type ?? "Standard"})'),
                  subtitle: Text(
                      '${stock.quantityKg} Kg | Fournisseur: ${stock.supplier ?? "N/A"}'),
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
                          await SupabaseService().deleteStockInk(stock.id!);
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
