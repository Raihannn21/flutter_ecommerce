// lib/models/colour_model.dart
class Colour {
  final int id;
  final String name;

  Colour({required this.id, required this.name});

  factory Colour.fromJson(Map<String, dynamic> json) {
    return Colour(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
