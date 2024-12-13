import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/notifier/login_notifier.dart';
import 'package:movie_date/pages/register_page.dart';

// Providers for state management
final loginProvider = StateNotifierProvider<LoginNotifier, bool>((ref) => LoginNotifier());
final emailControllerProvider = Provider((ref) => TextEditingController());
final passwordControllerProvider = Provider((ref) => TextEditingController());

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loginProvider);
    final emailController = ref.read(emailControllerProvider);
    final passwordController = ref.read(passwordControllerProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/movieDate.png',
                height: 100,
              ),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  text: 'Movie',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Date',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'EMAIL',
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'PASSWORD',
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                ref.read(loginProvider.notifier).signIn(
                                      context,
                                      emailController.text,
                                      passwordController.text,
                                    );
                              },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'LOG IN',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(RegisterPage.route());
                      },
                      child: const Text(
                        'No account yet? Sign up.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
