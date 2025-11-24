import 'package:flutter/material.dart';
import 'package:ideal_calcule/pages/calculator_host_page.dart';
import 'package:ideal_calcule/class/font_size_provider.dart';
import 'package:ideal_calcule/theme/app_theme.dart';

// Global notifier for theme switching
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved font size
  final savedFontSize = await FontSizeProvider.loadFontSize();
  fontSizeNotifier.value = savedFontSize;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
