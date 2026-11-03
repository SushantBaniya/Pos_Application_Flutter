import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_app/notifiers/login_notifiers.dart';
import 'package:pos_app/Screens/home_screen.dart';

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
  bool _rememberMe = false;
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
    final loginState = ref.watch(loginNotifierProvider);

    ref.listen(loginNotifierProvider, (previous, next) {
      next.when(
        data: (data) {
          if (data != null && context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
        },
        loading: () {
          // s
        },
        error: (error, stackTrace) {
          // Handle login error, e.g., show a snackbar or dialog
          debugPrint('Login failed: $error');
        },
      );
    });
    return Column(
      children: [
        const SizedBox(height: 40),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email, color: Color(0xFF101B55)),
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          obscureText: true,
          controller: passwordController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF101B55)),
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: _rememberMe, // You can manage this state as needed
              onChanged: (value) {
                ref.read(rememberMeProvider.notifier).setRememberMe(value ?? true);
              },
            ),
            Text('Remember Me', style: TextStyle(color: Color(0xFF101B55))),
            const Spacer(), // Pushes the "Forgot Password?" button to the right
            TextButton(
              onPressed: () {
                // Handle forgot password logic here
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(0xFF101B55),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        ElevatedButton( // Dont need to style this button as it will inherit the style from the theme defined in main.dart
          onPressed: loginState.isLoading
              ? null
              : () {
            final email = emailController.text.trim();
            final password = passwordController.text.trim();
            ref.read(loginNotifierProvider.notifier).login(email, password);
          },
          child: Text(
            loginState.isLoading ? 'Logging in...' : 'Login',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 40),
        Row(children: [
          Expanded(child: Divider(color: Colors.grey[400])),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('OR Continue with', style: TextStyle(color: Color(0xFF101B55))),
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
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signupResponse = ref.watch(signupNotifierProvider);
    return Column(
      children: [
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            labelText: 'Username',
            prefixIcon: const Icon(Icons.person, color: Color(0xFF101B55)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          ),
          controller: usernameController,
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email, color: Color(0xFF101B55)),
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          ),
          controller: emailController,
        ),
        const SizedBox(height: 20),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF101B55)),
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          ),
          controller: passwordController,
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone, color: Color(0xFF101B55)),
            labelText: 'Phone',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          ),
          controller: phoneController,
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.business, color: Color(0xFF101B55)),
            labelText: 'Business Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          ),
          controller: businessNameController,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            final username = usernameController.text.trim();
            final email = emailController.text.trim();
            final password = passwordController.text.trim();
            final phone = phoneController.text.trim();
            final businessName = businessNameController.text.trim();

            ref.read(signupNotifierProvider.notifier).signup(username, email, password, phone, businessName);
            signupResponse.when(
              data: (data) {
                if (data != null) {
                  // Handle successful signup, e.g., navigate to the home screen
                  debugPrint('Signup successful: ${data.message}');
                }
              },
              loading: () {
                // Optionally show a loading indicator
                debugPrint('Signing up...');
              },
              error: (error, stackTrace) {
                // Handle signup error, e.g., show a snackbar or dialog
                debugPrint('Signup failed: $error');
              },
            );
          },
          child: const Text('Signup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
