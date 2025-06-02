import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart'; // Import AuthService
import 'package:frontend/screens/auth/register_screen.dart'; // Untuk navigasi ke Register
import 'package:frontend/screens/home/home_screen.dart'; // Untuk Home Screen
import 'package:shared_preferences/shared_preferences.dart'; // Untuk penyimpanan token
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'package:frontend/models/user.dart'; // <<<<<<<<<< PENTING: Tambahkan ini

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService(); // Inisialisasi AuthService

  bool _isLoading = false; // State untuk indikator loading

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (response['success']) {
        // Login berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        final String? token = response['data']['token'];
        final userObject =
            response['data']['user']; // Ini sudah objek User dari AuthService

        // <<<<<<<<<< LOGIKA PENYIMPANAN TOKEN & USER DATA (PERBAIKAN)
        if (kDebugMode) {
          print('Login Response Data: ${response['data']}');
          print('Token received from API: $token');
          print(
              'User object received from API: ${userObject.runtimeType} -> $userObject'); // Sekarang ini adalah objek User
        }

        if (token != null && token.isNotEmpty && userObject != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          // Simpan objek User sebagai JSON string
          await prefs.setString(
              'user_data',
              jsonEncode(userObject
                  .toJson())); // <<<<<< PENTING: encode User object ke JSON string

          if (kDebugMode) {
            final String? storedToken = prefs.getString('auth_token');
            final String? storedUserData = prefs.getString('user_data');
            print('Token saved to SharedPreferences: $storedToken');
            print(
                'User Data saved to SharedPreferences: $storedUserData'); // Ini akan jadi JSON string
          }
        } else {
          if (kDebugMode) {
            print(
                'Token or User object is null/empty from login response. Cannot save.');
          }
        }
        // <<<<<<<<<< AKHIR PERBAIKAN LOGIKA

        // Navigasi ke halaman utama setelah login (HomeScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Login gagal, tampilkan pesan error
        String errorMessage = response['message'] ?? 'Login failed.';
        if (response['errors'] != null) {
          response['errors'].forEach((key, value) {
            errorMessage += '\n${value[0]}';
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/app_logo.png',
                  height: 120,
                ),
                const SizedBox(height: 32.0),
                const Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Login to continue your shopping experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Don\'t have an account? Register Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
