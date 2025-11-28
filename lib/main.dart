import 'package:flutter/material.dart';
import 'package:ideal_calcule/pages/calculator_host_page.dart';
import 'package:ideal_calcule/class/font_size_provider.dart';
import 'package:ideal_calcule/theme/app_theme.dart';
import 'package:ideal_calcule/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  try {
    await DatabaseHelper().database;
    print('✅ Base de données initialisée avec succès');
  } catch (e) {
    print('❌ Erreur initialisation base de données: $e');
  }

  // Load saved font size
  final savedFontSize = await FontSizeProvider.loadFontSize();
  fontSizeNotifier.value = savedFontSize;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Global notifier for theme switching
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return ValueListenableBuilder<double>(
          valueListenable: fontSizeNotifier,
          builder: (context, fontScale, _) {
            return MaterialApp(
              title: 'Ideal Calcule',
              debugShowCheckedModeBanner: false,
              themeMode: currentMode,
              theme: AppTheme.lightTheme(fontScale),
              darkTheme: AppTheme.darkTheme(fontScale),
              home: const CalculatorHostPage(),
            );
          },
        );
      },
    );
  }
}
