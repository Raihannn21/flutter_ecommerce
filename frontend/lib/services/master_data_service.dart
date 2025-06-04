import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_constants.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../models/product_type_model.dart';
import '../models/colour_model.dart';
import '../models/usage_model.dart';

class MasterDataService {
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('MasterData API Response Status Code: ${response.statusCode}');
      print(
          'MasterData API Response FULL Body (Untruncated): ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          if (jsonResponse.containsKey('data') &&
              jsonResponse['data'] is List) {
            return {
              'success': true,
              'data': jsonResponse['data'],
              'statusCode': response.statusCode,
            };
          } else {
            if (kDebugMode) {
              print(
                  'MasterDataService Error: API response "data" key is missing or not a list.');
            }
            return {
              'success': false,
              'message':
                  'Invalid API response structure: "data" key missing or not a list.',
              'statusCode': response.statusCode,
              'body': response.body,
            };
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                'MasterDataService Error: Failed to decode JSON body for 2xx response: $e');
            print('MasterDataService Error: Raw body: ${response.body}');
          }
          return {
            'success': false,
            'message':
                'Failed to parse successful API response JSON. Error: $e',
            'statusCode': response.statusCode,
            'body': response.body,
          };
        }
      } else {
        return {
          'success': true,
          'data': [],
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
          'errors': errorBody['errors'],
          'statusCode': response.statusCode,
        };
      } catch (e) {
        if (kDebugMode) {
          print('MasterData API Error parsing non-200 response as JSON: $e');
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

  Future<List<ProductCategory>> getCategories() async {
    final response = await http.get(Uri.parse(ApiConstants.categoriesEndpoint),
        headers: {'Accept': 'application/json'});
    final handledResponse = _handleResponse(response);
    if (handledResponse['success']) {
      return (handledResponse['data'] as List<dynamic>)
          .map((json) => ProductCategory.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<Subcategory>> getSubcategories({int? categoryId}) async {
    String url = ApiConstants.subcategoriesEndpoint;
    if (categoryId != null) {
      url += '?category_id=$categoryId';
    }
    final response =
        await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});
    final handledResponse = _handleResponse(response);
    if (handledResponse['success']) {
      return (handledResponse['data'] as List<dynamic>)
          .map((json) => Subcategory.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<ProductTypeModel>> getProductTypes({int? subcategoryId}) async {
    String url = ApiConstants.productTypesEndpoint;
    if (subcategoryId != null) {
      url += '?subcategory_id=$subcategoryId';
    }
    final response =
        await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});
    final handledResponse = _handleResponse(response);
    if (handledResponse['success']) {
      return (handledResponse['data'] as List<dynamic>)
          .map((json) => ProductTypeModel.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<Colour>> getColours() async {
    final response = await http.get(Uri.parse(ApiConstants.coloursEndpoint),
        headers: {'Accept': 'application/json'});
    final handledResponse = _handleResponse(response);
    if (handledResponse['success']) {
      return (handledResponse['data'] as List<dynamic>)
          .map((json) => Colour.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<Usage>> getUsages() async {
    final response = await http.get(Uri.parse(ApiConstants.usagesEndpoint),
        headers: {'Accept': 'application/json'});
    final handledResponse = _handleResponse(response);
    if (handledResponse['success']) {
      return (handledResponse['data'] as List<dynamic>)
          .map((json) => Usage.fromJson(json))
          .toList();
    }
    return [];
  }

  // <<<<<<<<<< TAMBAHAN: Metode untuk memanggil Binary Search API Subcategory
  Future<Map<String, dynamic>> binarySearchSubcategoryById(int id) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConstants.baseUrl}/subcategories/binary-search-by-id?id=$id'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (kDebugMode) {
      print('Binary Search API Response Status Code: ${response.statusCode}');
      print('Binary Search API Response Body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return {
        'success': true,
        'data': Subcategory.fromJson(
            jsonResponse['data']), // Parse Subcategory object
        'message': jsonResponse['message'] ?? 'Subcategory found.',
        'search_steps': jsonResponse['search_steps'],
      };
    } else {
      try {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Subcategory not found.',
          'search_steps': errorBody[
              'search_steps'], // Ambil langkah dari error response juga
        };
      } catch (e) {
        if (kDebugMode) {
          print('Binary Search API Error parsing response as JSON: $e');
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
  // <<<<<<<<<< AKHIR TAMBAHAN
}
