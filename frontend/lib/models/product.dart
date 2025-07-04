class Product {
  final int productId;
  final int genderId;
  final int productTypeId;
  final int colourId;
  final int usageId;
  final String title;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.productId,
    required this.genderId,
    required this.productTypeId,
    required this.colourId,
    required this.usageId,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] as int,
      genderId: json['gender_id'] as int,
      productTypeId: json['product_type_id'] as int,
      colourId: json['colour_id'] as int,
      usageId: json['usage_id'] as int,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Method untuk mengubah objek Product menjadi JSON (opsional, berguna untuk POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'gender_id': genderId,
      'product_type_id': productTypeId,
      'colour_id': colourId,
      'usage_id': usageId,
      'title': title,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
