class Task {
  final int? id;
  final String title;
  final bool isDone;

  Task({this.id, required this.title, required this.isDone});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'isDone': isDone ? 1 : 0};
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1 || map['isDone'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'isDone': isDone};
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      title: json['title'],
      isDone: json['isDone'] == true || json['isDone'] == 1,
    );
  }
}
