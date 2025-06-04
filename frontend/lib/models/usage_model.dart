class Usage {
  final int id;
  final String name;

  Usage({required this.id, required this.name});

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
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
