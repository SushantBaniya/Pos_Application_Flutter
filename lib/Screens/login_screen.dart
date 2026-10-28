import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_app/notifiers/login_notifiers.dart';

class Options extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void set(int value) {
    state = value;
  }
}

final optionsProvider = NotifierProvider<Options, int>(() => Options());

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Login_image.jpg', fit: BoxFit.cover),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Text(
                  'Welcome to Pasale POS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withAlpha(179),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sign up-in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withAlpha(179),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Expanded(child: MainSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainSection extends ConsumerStatefulWidget {
  const MainSection({super.key});

  @override
  ConsumerState<MainSection> createState() => _MainSectionState();
}

class _MainSectionState extends ConsumerState<MainSection> {
  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(optionsProvider);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: ref.watch(optionsProvider),
                children: const {0: Text('Login'), 1: Text('Sign Up')},
                onValueChanged: (value) {
                  if (value != null) {
                    ref.read(optionsProvider.notifier).set(value);
                  }
                },
              ),
            ),
            tab == 0 ? const LoginForm() : const SignUpForm(),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginResponse = ref.watch(loginNotifierProvider);
    return Column(
      children: [
        const SizedBox(height: 40),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email, color: Colors.green),
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          obscureText: true,
          controller: passwordController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Colors.green),
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Remember me", style: TextStyle(color: Colors.grey[600])),
            TextButton(
              onPressed: () {
                // Handle forgot password logic here
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.green,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        ElevatedButton( // Dont need to style this button as it will inherit the style from the theme defined in main.dart
          onPressed: () {
            final email = emailController.text.trim();
            final password = passwordController.text.trim();
            ref.read(loginNotifierProvider.notifier).login(email, password);
            loginResponse.when(
              data: (data) {
                if (data != null) {
                  // Handle successful login, e.g., navigate to the home screen
                  debugPrint('Login successful:');
                }
              },
              loading: () {
                // Optionally show a loading indicator
                debugPrint('Logging in...');
              },
              error: (error, stackTrace) {
                // Handle login error, e.g., show a snackbar or dialog
                debugPrint('Login failed: $error');
              },
            );
          },
          child: const Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 40),
        Row(children: [
          Expanded(child: Divider(color: Colors.grey[400])),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('OR Continue with', style: TextStyle(color: Colors.green)),
          ),
          Expanded(child: Divider(color: Colors.grey[400]))
        ],),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Handle Google login logic here
              },
              icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 40),
              label: const Text('Google', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(150, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: Colors.black.withAlpha(50))),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Handle Facebook login logic here
              },
              icon: const Icon(Icons.facebook, color: Colors.blue, size: 40),
              label: const Text('Facebook', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(150, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: Colors.black.withAlpha(50))),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // button color
            foregroundColor: Colors.white, // text and icon color
            minimumSize: const Size(double.infinity, 52), // full width, 52 tall
            elevation: 2, // shadow depth (0 = flat)
            shadowColor: Colors.black45,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
