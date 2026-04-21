import '../models/note_models.dart';
import '../services/database_service.dart';

class NoteRepository {
  Future<int> insert(Note note) async {
    final db = await DatabaseService.database;
    return db.insert('notes', note.toMap());
  }

  Future<int> update(Note note) async {
    final db = await DatabaseService.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseService.database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // JOIN để lấy tên category
  Future<List<Note>> getAll({int? categoryId}) async {
    final db = await DatabaseService.database;

    var query = '''
      SELECT notes.*, categories.name as categoryName
      FROM notes
      INNER JOIN categories ON notes.categoryId = categories.id
    ''';
    final args = <Object?>[];

    if (categoryId != null) {
      query += ' WHERE notes.categoryId = ?';
      args.add(categoryId);
    }

    query += ' ORDER BY notes.id DESC';

    final result = await db.rawQuery(query, args);

    return result.map((e) => Note.fromMap(e)).toList();
  }
}
