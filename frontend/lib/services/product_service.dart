import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_constants.dart';
import '../models/product.dart'; // Import model Product

class ProductService {
  // Metode untuk mengambil daftar semua produk dengan pagination
  Future<Map<String, dynamic>> getProducts(
      {int page = 1, int perPage = 20}) async {
    final Uri uri = Uri.parse(
        '${ApiConstants.productsEndpoint}?page=$page&per_page=$perPage');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (kDebugMode) {
      print('Products API Response Status Code: ${response.statusCode}');
      print('Products API Response Body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      List<dynamic> productJsonList = jsonResponse['data'];
      List<Product> products =
          productJsonList.map((json) => Product.fromJson(json)).toList();

      Map<String, dynamic> paginationMeta = jsonResponse['pagination'] ?? {};

      return {
        'success': true,
        'data': products,
        'pagination': paginationMeta,
        'message':
            jsonResponse['message'] ?? 'Products retrieved successfully.',
      };
    } else {
      try {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to retrieve products.',
          'errors': errorBody['errors'],
        };
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing products response as JSON: $e');
        }
        return {
          'success': false,
          'message':
              'Failed to parse API response. Status Code: ${response.statusCode}. Raw body: ${response.body}',
          'body': response.body,
        };
      }
    }
  }

  // Metode untuk mengambil detail satu produk
  Future<Map<String, dynamic>> getProductDetail(String productId) async {
    final response = await http.get(
      Uri.parse(ApiConstants.productDetailEndpoint(productId)),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (kDebugMode) {
      print('Product Detail API Response Status Code: ${response.statusCode}');
      print('Product Detail API Response Body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      Product product = Product.fromJson(jsonResponse['data']);
      return {
        'success': true,
        'data': product,
        'message': jsonResponse['message'] ?? 'Product retrieved successfully.',
      };
    } else {
      try {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              errorBody['message'] ?? 'Failed to retrieve product detail.',
          'errors': errorBody['errors'],
        };
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing product detail response as JSON: $e');
        }
        return {
          'success': false,
          'message':
              'Failed to parse API response. Status Code: ${response.statusCode}. Raw body: ${response.body}',
          'body': response.body,
        };
      }
    }
  }

  // Metode untuk membuat produk baru (Admin)
  Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> productData, String adminToken) async {
    final response = await http.post(
      Uri.parse(ApiConstants.adminProductsEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $adminToken',
      },
      body: jsonEncode(productData),
    );

    if (kDebugMode) {
      print('Create Product API Response Status Code: ${response.statusCode}');
      print('Create Product API Response Body: ${response.body}');
    }

    return _handleResponse(response);
  }

  // Metode untuk memperbarui produk (Admin)
  Future<Map<String, dynamic>> updateProduct(String productId,
      Map<String, dynamic> productData, String adminToken) async {
    final response = await http.put(
      Uri.parse(ApiConstants.adminProductUpdateEndpoint(productId)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $adminToken',
      },
      body: jsonEncode(productData),
    );

    if (kDebugMode) {
      print('Update Product API Response Status Code: ${response.statusCode}');
      print('Update Product API Response Body: ${response.body}');
    }

    return _handleResponse(response);
  }

  // Metode untuk menghapus produk (Admin)
  Future<Map<String, dynamic>> deleteProduct(
      String productId, String adminToken) async {
    final response = await http.delete(
      Uri.parse(ApiConstants.adminProductDeleteEndpoint(productId)),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $adminToken',
      },
    );

    if (kDebugMode) {
      print('Delete Product API Response Status Code: ${response.statusCode}');
      print('Delete Product API Response Body: ${response.body}');
    }

    return _handleResponse(response);
  }

  // Fungsi helper untuk menangani respons HTTP (sudah ada)
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': true,
          'data': {},
          'statusCode': response.statusCode,
          'message': 'No content',
        };
      }
    } else {
      try {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'An error occurred',
          'errors': errorBody['errors'],
          'statusCode': response.statusCode,
        };
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing response as JSON: $e');
        }
        return {
          'success': false,
          'message':
              'Failed to parse API response. Status Code: ${response.statusCode}. Raw body: ${response.body}',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    }
  }
}
