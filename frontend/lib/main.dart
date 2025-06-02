import 'package:flutter/material.dart';
// import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/auth/splash_screen.dart';
// import 'package:frontend/screens/auth/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce App',
      theme: ThemeData(
        // <<<<<<<<<< PERUBAHAN TEMA DIMULAI DI SINI
        primarySwatch:
            Colors.blue, // Warna dasar, akan menghasilkan berbagai shade biru
        // Atau Anda bisa menggunakan warna spesifik:
        // primaryColor: const Color(0xFF42A5F5), // Contoh warna biru muda
        // accentColor: const Color(0xFFFFC107), // Contoh warna kuning untuk aksen

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // Warna AppBar
          foregroundColor: Colors.white, // Warna teks dan ikon di AppBar
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8.0), // Border melengkung untuk input
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
                color: Colors.blue, width: 2.0), // Border fokus lebih tebal
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
                color: Colors.grey.shade400), // Border saat tidak fokus
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Warna tombol ElevatedButton
            foregroundColor: Colors.white, // Warna teks tombol
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8.0), // Bentuk tombol melengkung
            ),
            textStyle: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue, // Warna teks tombol TextButton
          ),
        ),
        // <<<<<<<<<< PERUBAHAN TEMA SELESAI
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Halaman awal masih RegisterScreen
    );
  }
}
