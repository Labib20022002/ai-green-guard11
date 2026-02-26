import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AIGreenGuardApp());
}

class AIGreenGuardApp extends StatelessWidget {
  const AIGreenGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI-GreenGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(), // 🔹 Only routing
    );
  }
}