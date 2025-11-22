import 'package:flutter/material.dart';
import 'package:ideal_calcule/pages/calculator_host_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ideal Calcule',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
      home: const CalculatorHostPage(),
    );
  }
}
