import 'package:flutter/material.dart';
import 'package:pos_app/Screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/Screens/home_screen.dart';
import 'package:pos_app/notifiers/providers.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF101B55),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            elevation: 2,
            shadowColor: Colors.black45,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: const StadiumBorder(),
            
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStartup = ref.watch(authStartupProvider);

    return authStartup.when(
      data: (_) {
        // If the user is remembered and has a valid access token, navigate to the home screen
        return const HomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        // If there's an error or the user is not remembered, navigate to the login screen
        return const LoginScreen();
      },
    );
  }
}