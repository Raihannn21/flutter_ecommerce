// lib/models/subcategory_model.dart
import 'category_model.dart'; // Penting: Pastikan ini mengimpor category_model.dart

class Subcategory {
  final int id;
  final String name;
  final int categoryId;

  Subcategory({required this.id, required this.name, required this.categoryId});

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] as int,
      name: json['name'] as String,
      categoryId: json['category_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
    };
  }
}
