import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const LostFoundApp());
}

class LostFoundApp extends StatelessWidget {
  const LostFoundApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Lost & Found',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
