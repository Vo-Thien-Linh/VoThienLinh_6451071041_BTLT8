class Note {
  final int? id;
  final String title;
  final String content;
  final int categoryId;
  final String? categoryName; // để join hiển thị

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    this.categoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'categoryId': categoryId,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      categoryId: map['categoryId'],
      categoryName: map['categoryName'], // từ JOIN
    );
  }
}