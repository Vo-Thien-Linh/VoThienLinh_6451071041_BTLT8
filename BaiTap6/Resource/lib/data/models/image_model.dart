class ImageModel {
  final int? id;
  final String path;
  final DateTime createdAt;

  ImageModel({this.id, required this.path, required this.createdAt});

  /// Convert to Map for database
  Map<String, dynamic> toMap() {
    return {'id': id, 'path': path, 'createdAt': createdAt.toIso8601String()};
  }

  /// Create from Map from database
  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      id: map['id'] as int?,
      path: map['path'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Copy with method for immutability
  ImageModel copyWith({int? id, String? path, DateTime? createdAt}) {
    return ImageModel(
      id: id ?? this.id,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'ImageModel(id: $id, path: $path, createdAt: $createdAt)';
}
