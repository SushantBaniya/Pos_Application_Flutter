import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/Screens/login_screen.dart';
import 'package:pos_app/services/token_storage.dart';

void main() {
  ProviderScope(
    child: const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'POS App',
      home: LoginScreen(),
    );
  }
}