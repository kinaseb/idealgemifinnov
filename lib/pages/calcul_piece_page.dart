import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalculPiecePage extends StatefulWidget {
  const CalculPiecePage({super.key});

  @override
  State<CalculPiecePage> createState() => _CalculPiecePageState();
}

class _CalculPiecePageState extends State<CalculPiecePage> {
  final _hauteurController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _metrageStockController = TextEditingController();

  double _metrageNecessaire = 0.0;
  int _nombreDePieces = 0;

  final NumberFormat _numberFormat = NumberFormat("#,###.##", "fr_FR");

  @override
  void initState() {
    super.initState();
    _hauteurController.addListener(_recalculateAll);
    _quantiteController.addListener(_recalculateAll);
    _metrageStockController.addListener(_recalculateAll);
  }

  @override
  void dispose() {
    _hauteurController.dispose();
    _quantiteController.dispose();
    _metrageStockController.dispose();
    super.dispose();
  }

  void _recalculateAll() {
    // We call setState only once at the end of all calculations.
    final hauteur = double.tryParse(_hauteurController.text.replaceAll(',', '.')) ?? 0.0;
    final quantite = int.tryParse(_quantiteController.text.replaceAll(' ', '')) ?? 0;
    final metrageStock = double.tryParse(_metrageStockController.text.replaceAll(',', '.')) ?? 0.0;

    double newMetrageNecessaire = 0.0;
    if (hauteur > 0 && quantite > 0) {
      newMetrageNecessaire = (hauteur * quantite) / 1000.0;
    }

    int newNombreDePieces = 0;
    if (metrageStock > 0 && hauteur > 0) {
      newNombreDePieces = ((metrageStock * 1000) / hauteur).floor();
    }
    
    setState(() {
      _metrageNecessaire = newMetrageNecessaire;
      _nombreDePieces = newNombreDePieces;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMetrageCalculator(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              _buildPieceCalculator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetrageCalculator() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Calcul de métrage nécessaire",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _hauteurController,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Hauteur de la pièce (mm)',
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantiteController,
                    style: const TextStyle(fontSize: 22),
                    decoration: const InputDecoration(
                      labelText: 'Quantité voulue',
                      prefixIcon: Icon(Icons.production_quantity_limits),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final currentValue = int.tryParse(_quantiteController.text.replaceAll(' ', '')) ?? 0;
                    _quantiteController.text = (currentValue * 1000).toString();
                  },
                  child: const Text('1K'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Métrage nécessaire: ${_numberFormat.format(_metrageNecessaire)} m",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieceCalculator() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Calcul de pièces par métrage",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _metrageStockController,
                    style: const TextStyle(fontSize: 22),
                    decoration: const InputDecoration(
                      labelText: 'Métrage en stock (m)',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final currentValue = double.tryParse(_metrageStockController.text.replaceAll(',', '.')) ?? 0.0;
                    _metrageStockController.text = (currentValue * 1000).toString().replaceAll('.', ',');
                  },
                  child: const Text('1K'),
                )
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Nombre de pièces: ${_numberFormat.format(_nombreDePieces)}",
                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
