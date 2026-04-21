import 'package:sqflite/sqflite.dart';
import '../models/note_models.dart';
import '../services/database_service.dart';

class NoteRepository {

  Future<List<Note>> getAllNotes() async {
    final db = await DatabaseService.database;
    final result = await db.query('notes');
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> insertNote(Note note) async {
    final db = await DatabaseService.database;
    return await db.insert('notes', note.toMap());
  }

  Future<int> updateNote(Note note) async {
    final db = await DatabaseService.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}