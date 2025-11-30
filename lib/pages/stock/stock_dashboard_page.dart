import 'package:flutter/material.dart';
import 'stock_support_page.dart';
import 'stock_ink_page.dart';
import 'stock_plate_page.dart';

class StockDashboardPage extends StatelessWidget {
  const StockDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Stocks'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildStockCard(
            context,
            'Supports', // Renamed from Papier
            Icons.article,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StockSupportPage()),
            ),
          ),
          _buildStockCard(
            context,
            'Encre',
            Icons.format_paint,
            Colors.red,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StockInkPage()),
            ),
          ),
          _buildStockCard(
            context,
            'Clichés',
            Icons.layers,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StockPlatePage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
