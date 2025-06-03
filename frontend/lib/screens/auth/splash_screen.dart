import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/home/home_screen.dart'; // Untuk Home Screen
import 'package:frontend/screens/auth/login_screen.dart'; // Untuk Login Screen
import 'package:frontend/services/auth_service.dart'; // <<<<<<<<<< PENTING: Uncomment ini
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'dart:convert'; // <<<<<<<<<< PENTING: Tambahkan ini untuk jsonDecode
import 'package:frontend/models/user.dart'; // <<<<<<<<<< PENTING: Tambahkan ini untuk model User

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Panggil fungsi untuk memeriksa status login
  }

  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    // Ambil data user dari SharedPreferences sebagai JSON string
    final String? userDataString =
        prefs.getString('user_data'); // <<<<<<<<<< TAMBAHAN

    if (kDebugMode) {
      print('Splash Screen: Checking login status...');
      print('Splash Screen: Token from SharedPreferences: $token');
      print(
          'Splash Screen: User Data String from SharedPreferences: $userDataString'); // <<<<<<<<<< TAMBAHAN
    }

    // Beri waktu sebentar untuk melihat splash screen
    await Future.delayed(
        const Duration(seconds: 5)); // Tampilkan splash screen selama 3 detik

    if (mounted) {
      // Pastikan widget masih di tree sebelum navigasi
      if (token != null && token.isNotEmpty) {
        AuthService authService = AuthService();
        final response = await authService
            .getUserInfo(token); // Panggil API untuk verifikasi

        if (kDebugMode) {
          print(
              'Splash Screen: API User Info Response: ${response['success']}');
          if (response['success']) {
            // response['data'] sekarang adalah objek User
            User currentUser = response['data'] as User;
            print(
                'Splash Screen: Logged in User Role from API: ${currentUser.role}');
          } else {
            print(
                'Splash Screen: API User Info Error Message: ${response['message']}');
          }
        }

        if (response['success']) {
          // Token valid dan user info berhasil didapat
          // Simpan ulang user data yang mungkin lebih update dari API
          User currentUser =
              response['data'] as User; // Ambil user object dari response
          await prefs.setString('user_data',
              jsonEncode(currentUser.toJson())); // Simpan sebagai JSON string

          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Token invalid atau expired, hapus dan arahkan ke login
          if (kDebugMode) {
            print(
                'Splash Screen: Token invalid or expired, removing token and navigating to LoginScreen.');
          }
          await prefs.remove('auth_token'); // Hapus token yang tidak valid
          await prefs
              .remove('user_data'); // <<<<<<<<<< PENTING: Hapus juga user_data
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        // Tidak ada token, arahkan ke halaman login
        if (kDebugMode) {
          print('Splash Screen: No token found, navigating to LoginScreen.');
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700], // Warna latar belakang splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Aplikasi
            Image.asset(
              'assets/app_logo.png', // Logo yang sudah Anda siapkan
              width: 150, // Ukuran logo
              height: 150,
            ),
            const SizedBox(height: 24.0),
            // Nama Aplikasi
            const Text(
              'E-commerce App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5, // Spasi antar huruf
              ),
            ),
            const SizedBox(height: 16.0),
            // Indikator loading (opsional)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white), // Warna loading putih
            ),
          ],
        ),
      ),
    );
  }
}
