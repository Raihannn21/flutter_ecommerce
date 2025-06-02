import 'dart:convert'; // Untuk encode/decode JSON
import 'package:http/http.dart' as http; // Import paket http
import '../config/api_constants.dart'; // Import konstanta API
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import '../models/user.dart'; // <<<<<<<<<< PENTING: Tambahkan ini untuk model User

class AuthService {
  // Endpoint untuk registrasi user baru
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.registerEndpoint), // URL endpoint register
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    // Langsung kembalikan hasil dari _handleResponse
    return _handleResponse(response);
  }

  // Endpoint untuk login user
  // <<<<<<<<<< PERBAIKAN DI SINI: Parsing User model
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginEndpoint), // URL endpoint login
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final Map<String, dynamic> handledResponse = _handleResponse(response);

    if (handledResponse['success']) {
      // Jika respons sukses, parse objek user dari handledResponse['data']['user']
      // Laravel mengembalikan {"user": {...}, "token": "..."}
      final Map<String, dynamic> responseData = handledResponse['data'];
      User user = User.fromJson(responseData['user']);
      String token = responseData['token'];

      return {
        'success': true,
        'data': {
          'user': user,
          'token': token
        }, // Kembalikan objek User dan token
        'statusCode': handledResponse['statusCode'],
      };
    } else {
      return handledResponse; // Jika ada error, kembalikan error dari _handleResponse
    }
  }
  // <<<<<<<<<< AKHIR PERBAIKAN

  // Endpoint untuk logout user
  Future<Map<String, dynamic>> logout(String token) async {
    final response = await http.post(
      Uri.parse(ApiConstants.logoutEndpoint), // URL endpoint logout
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Mengirim token di header
      },
    );

    return _handleResponse(response);
  }

  // <<<<<<<<<< PERBAIKAN DI SINI: Parsing User model untuk getUserInfo
  // Endpoint untuk mengambil informasi user yang sedang login
  Future<Map<String, dynamic>> getUserInfo(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.userEndpoint), // URL endpoint /api/user
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Mengirim token di header
      },
    );

    final Map<String, dynamic> handledResponse = _handleResponse(response);

    if (kDebugMode) {
      print('User Info API Response Status Code: ${response.statusCode}');
      print('User Info API Response Body: ${response.body}');
    }

    if (handledResponse['success']) {
      // Jika respons sukses, parse objek user dari handledResponse['data']
      // Endpoint /api/user mengembalikan objek user langsung
      return {
        'success': true,
        'data':
            User.fromJson(handledResponse['data']), // Data adalah objek User
        'statusCode': handledResponse['statusCode'],
      };
    } else {
      return handledResponse; // Jika ada error, kembalikan error dari _handleResponse
    }
  }
  // <<<<<<<<<< AKHIR PERBAIKAN

  // Fungsi helper untuk menangani respons HTTP
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Sukses: 2xx responses
      // Pastikan body tidak kosong sebelum decode
      if (response.body.isNotEmpty) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else {
        // Handle 204 No Content atau body kosong
        return {
          'success': true,
          'data': {}, // Data kosong
          'statusCode': response.statusCode,
          'message': 'No content',
        };
      }
    } else {
      // Error: 4xx, 5xx responses
      try {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'An error occurred',
          'errors': errorBody['errors'], // Untuk error validasi
          'statusCode': response.statusCode,
        };
      } catch (e) {
        // Jika respons bukan JSON (misal: HTML error page atau respons kosong)
        if (kDebugMode) {
          print('Error parsing response as JSON: $e');
        }
        return {
          'success': false,
          'message':
              'Failed to parse API response. Status Code: ${response.statusCode}. Raw body: ${response.body}',
          'statusCode': response.statusCode,
          'body': response.body, // Sertakan body agar bisa di-debug
        };
      }
    }
  }
}
