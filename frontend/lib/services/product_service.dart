import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_constants.dart';
import '../models/product.dart';

class ProductService {
  Future<Map<String, dynamic>> getProducts(
      {int page = 1, int perPage = 20}) async {
    String url =
        '${ApiConstants.productsEndpoint}?page=$page&per_page=$perPage';
    final Uri uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (kDebugMode) {
      print('Products API Response Status Code: ${response.statusCode}');
      print('Products API Response FULL Body (Untruncated): ${response.body}');
    }

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (!jsonResponse.containsKey('data') ||
            !(jsonResponse['data'] is List)) {
          if (kDebugMode) {
            print(
                'ProductService Error: API response "data" key is missing or not a list.');
          }
          return {
            'success': false,
            'message':
                'Invalid API response structure: "data" key missing or not a list.',
            'statusCode': response.statusCode,
            'body': response.body,
          };
        }

        List<dynamic> productJsonList = jsonResponse['data'];
        List<Product> products = [];
        for (var item in productJsonList) {
          try {
            products.add(Product.fromJson(item));
          } catch (e) {
            if (kDebugMode) {
              print(
                  'ProductService Error: Failed to parse single product item: $item, Error: $e');
            }
          }
        }

        Map<String, dynamic> paginationMeta = jsonResponse['pagination'] ?? {};

        return {
          'success': true,
          'data': products,
          'pagination': paginationMeta,
          'message':
              jsonResponse['message'] ?? 'Products retrieved successfully.',
        };
      } catch (e) {
        if (kDebugMode) {
          print(
              'ProductService Error: Failed to decode or parse JSON response. Error: $e');
          print(
              'ProductService Error: Raw response body that caused error: ${response.body}');
        }
        return {
          'success': false,
          'message': 'Failed to parse API response JSON. Error: $e',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } else {
      try {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to retrieve products.',
          'errors': errorBody['errors'],
          'statusCode': response.statusCode,
        };
      } catch (e) {
        if (kDebugMode) {
          print(
              'ProductService Error: Failed to parse non-200 error response as JSON: $e');
        }
        return {
          'success': false,
          'message':
              'Failed to parse API error response. Status Code: ${response.statusCode}. Raw body: ${response.body}',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    }
  }

  Future<Map<String, dynamic>> binarySearchProductsBySubcategoryName(
      {int page = 1, int perPage = 20, String searchQuery = ''}) async {
    String url =
        '${ApiConstants.baseUrl}/products/search-by-subcategory-binary?page=$page&per_page=$perPage';
    if (searchQuery.isNotEmpty) {
      url += '&query=$searchQuery';
    }
    final Uri uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (kDebugMode) {
      print(
          'Products Binary Search by Subcategory API Response Status Code: ${response.statusCode}');
      print(
          'Products Binary Search by Subcategory API Response FULL Body (Untruncated): ${response.body}');
    }

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (!jsonResponse.containsKey('data') ||
            !(jsonResponse['data'] is List)) {
          if (kDebugMode) {
            print(
                'ProductService Error: API response "data" key is missing or not a list.');
          }
          return {
            'success': false,
            'message':
                'Invalid API response structure: "data" key missing or not a list.',
            'statusCode': response.statusCode,
            'body': response.body,
          };
        }

        List<dynamic> productJsonList = jsonResponse['data'];
        List<Product> products = [];
        for (var item in productJsonList) {
          try {
            products.add(Product.fromJson(item));
          } catch (e) {
            if (kDebugMode) {
              print(
                  'ProductService Error: Failed to parse single product item: $item, Error: $e');
            }
          }
        }

        Map<String, dynamic> paginationMeta = jsonResponse['pagination'] ?? {};

        return {
          'success': true,
          'data': products,
          'pagination': paginationMeta,
          'message':
              jsonResponse['message'] ?? 'Products retrieved successfully.',
          'binary_search_steps_subcategory':
              jsonResponse['binary_search_steps_subcategory'],
        };
      } catch (e) {
        if (kDebugMode) {
          print(
              'ProductService Error: Failed to decode or parse JSON response. Error: $e');
          print(
              'ProductService Error: Raw response body that caused error: ${response.body}');
        }
        return {
          'success': false,
          'message': 'Failed to parse API response JSON. Error: $e',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } else {
      try {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to retrieve products.',
          'errors': errorBody['errors'],
          'statusCode': response.statusCode,
          'binary_search_steps_subcategory':
              errorBody['binary_search_steps_subcategory'],
        };
      } catch (e) {
        if (kDebugMode) {
          print(
              'ProductService Error: Failed to parse non-200 error response as JSON: $e');
        }
        return {
          'success': false,
          'message':
              'Failed to parse API error response. Status Code: ${response.statusCode}. Raw body: ${response.body}',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    }
  }

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
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        Product product = Product.fromJson(jsonResponse['data']);
        return {
          'success': true,
          'data': product,
          'message':
              jsonResponse['message'] ?? 'Product retrieved successfully.',
        };
      } catch (e) {
        if (kDebugMode) {
          print(
              'ProductService Error: Failed to parse product detail JSON: $e');
        }
        return {
          'success': false,
          'message': 'Failed to parse product detail API response. Error: $e',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } else {
      try {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              errorBody['message'] ?? 'Failed to retrieve product detail.',
          'errors': errorBody['errors'],
          'statusCode': response.statusCode,
        };
      } catch (e) {
        if (kDebugMode) {
          print(
              'ProductService Error: Failed to parse non-200 product detail error response: $e');
        }
        return {
          'success': false,
          'message':
              'Failed to parse API error response. Status Code: ${response.statusCode}. Raw body: ${response.body}',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    }
  }

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
