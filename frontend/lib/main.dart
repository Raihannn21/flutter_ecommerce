import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/splash_screen.dart'; // Pastikan ini diimpor

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
        primarySwatch:
            Colors.blue, // Warna dasar, akan menghasilkan berbagai shade biru
        primaryColor: const Color(0xFF1976D2), // Deep Blue
        hintColor: const Color(0xFFFFC107), // Amber for accents

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2), // Warna AppBar
          foregroundColor: Colors.white, // Warna teks dan ikon di AppBar
          elevation: 4.0, // Shadow di AppBar
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, // Input field akan memiliki background
          fillColor: Colors.blue.shade50, // Warna background input field
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12.0), // Border melengkung untuk input
            borderSide: BorderSide.none, // Hilangkan border default
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
                color: Color(0xFF1976D2),
                width: 2.0), // Border fokus lebih tebal
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
                color: Colors.grey.shade300), // Border saat tidak fokus
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0, horizontal: 16.0), // Padding dalam input
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF1976D2), // Warna tombol ElevatedButton
            foregroundColor: Colors.white, // Warna teks tombol
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12.0), // Bentuk tombol melengkung
            ),
            textStyle: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
            elevation: 5.0, // Tambahkan shadow pada tombol
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor:
                const Color(0xFF1976D2), // Warna teks tombol TextButton
            textStyle: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: const EdgeInsets.all(16.0),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Halaman awal masih SplashScreen
    );
  }
}
