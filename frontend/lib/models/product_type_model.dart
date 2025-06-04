// lib/models/product_type_model.dart
import 'subcategory_model.dart'; // Pastikan ini mengimpor subcategory_model.dart

class ProductTypeModel {
  final int id;
  final String name;
  final int subcategoryId;

  ProductTypeModel(
      {required this.id, required this.name, required this.subcategoryId});

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) {
    return ProductTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      subcategoryId: json['subcategory_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subcategory_id': subcategoryId,
    };
  }
}
