import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calculator_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Transparent status bar overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F14),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7A00),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Sans-Serif',
      ),
      home: const CalculatorScreen(),
    );
  }
}
