class DictionaryEntry {
  final int? id;
  final String word;
  final String meaning;

  DictionaryEntry({this.id, required this.word, required this.meaning});

  Map<String, dynamic> toMap() {
    return {'id': id, 'word': word, 'meaning': meaning};
  }

  factory DictionaryEntry.fromMap(Map<String, dynamic> map) {
    return DictionaryEntry(
      id: map['id'] as int?,
      word: map['word'] as String,
      meaning: map['meaning'] as String,
    );
  }
}
