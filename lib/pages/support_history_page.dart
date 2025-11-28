import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../class/support.dart';
import '../class/price_history.dart';
import '../services/database_helper.dart';

class SupportHistoryPage extends StatefulWidget {
  final Support support;

  const SupportHistoryPage({super.key, required this.support});

  @override
  State<SupportHistoryPage> createState() => _SupportHistoryPageState();
}

class _SupportHistoryPageState extends State<SupportHistoryPage> {
  late Future<List<PriceHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture =
        DatabaseHelper().getPriceHistory(widget.support.id!).then((data) {
      return data.map((e) => PriceHistory.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.support.name} History'),
      ),
      body: FutureBuilder<List<PriceHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No history found.'));
          }

          final history = snapshot.data!;
          // Sort by date ascending for the chart
          final chartData = List<PriceHistory>.from(history)
            ..sort((a, b) => a.date.compareTo(b.date));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < chartData.length) {
                                return Text(
                                    DateFormat('MM/dd')
                                        .format(chartData[value.toInt()].date),
                                    style: const TextStyle(fontSize: 10));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.price);
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        title: Text('${item.price.toStringAsFixed(2)} DA'),
                        subtitle: Text(
                            '${DateFormat('yyyy-MM-dd HH:mm').format(item.date)} - ${item.supplier ?? "N/A"}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
