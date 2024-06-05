import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/chat_provider.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _login(context, ref),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context, WidgetRef ref) {
    if (_formKey.currentState!.validate()) {
      final authService = ref.read(authenticationServiceProvider);
      authService.authenticate(
        _emailController.text,
        _passwordController.text,
      ).then((success) {
        if (success) {
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to login'),
          ));
        }
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      });
    }
  }
}
