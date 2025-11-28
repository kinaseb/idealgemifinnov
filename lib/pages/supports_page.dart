import 'package:flutter/material.dart';
import '../class/support.dart';
import '../class/price_history.dart';
import '../services/database_helper.dart';
import 'support_history_page.dart';

class SupportsPage extends StatefulWidget {
  const SupportsPage({super.key});

  @override
  State<SupportsPage> createState() => _SupportsPageState();
}

class _SupportsPageState extends State<SupportsPage> {
  late Future<List<Support>> _supportsFuture;

  @override
  void initState() {
    super.initState();
    _refreshSupports();
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
        title: Text(support == null ? 'Add Support' : 'Edit Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Support Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Current Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: supplierController,
              decoration: const InputDecoration(labelText: 'Supplier'),
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
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                final price = double.tryParse(priceController.text) ?? 0.0;

                if (support == null) {
                  // Add new
                  final newSupport = Support(
                    name: nameController.text,
                    currentPrice: price,
                    supplier: supplierController.text,
                  );
                  final id =
                      await DatabaseHelper().insertSupport(newSupport.toMap());

                  // Add initial history
                  await DatabaseHelper().insertPriceHistory(PriceHistory(
                    supportId: id,
                    price: price,
                    date: DateTime.now(),
                    supplier: supplierController.text,
                  ).toMap());
                } else {
                  // Update existing
                  final updatedSupport = Support(
                    id: support.id,
                    name: nameController.text,
                    currentPrice: price,
                    supplier: supplierController.text,
                  );
                  await DatabaseHelper().updateSupport(updatedSupport.toMap());

                  // Add history if price changed
                  if (price != support.currentPrice) {
                    await DatabaseHelper().insertPriceHistory(PriceHistory(
                      supportId: support.id!,
                      price: price,
                      date: DateTime.now(),
                      supplier: supplierController.text,
                    ).toMap());
                  }
                }

                if (mounted) Navigator.pop(context);
                _refreshSupports();
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No supports found.'));
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
                      'Price: ${support.currentPrice.toStringAsFixed(2)} DA | Supplier: ${support.supplier ?? "N/A"}'),
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
                          await DatabaseHelper().deleteSupport(support.id!);
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
