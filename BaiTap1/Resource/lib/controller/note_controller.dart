import '../data/models/note_models.dart';
import '../data/repository/note_repository.dart';

class NoteController {
  final NoteRepository _repo = NoteRepository();

  Future<List<Note>> getNotes() async {
    return await _repo.getAllNotes();
  }

  Future<void> addNote(String title, String content) async {
    await _repo.insertNote(
      Note(title: title, content: content),
    );
  }

  Future<void> updateNote(Note note) async {
    await _repo.updateNote(note);
  }

  Future<void> deleteNote(int id) async {
    await _repo.deleteNote(id);
  }
}