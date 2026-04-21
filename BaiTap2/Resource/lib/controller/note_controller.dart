import '../data/models/category_models.dart';
import '../data/models/note_models.dart';
import '../data/repository/category_repository.dart';
import '../data/repository/note_repository.dart';

class NoteController {
  final _noteRepo = NoteRepository();
  final _categoryRepo = CategoryRepository();

  Future<List<Note>> getNotes({int? categoryId}) {
    return _noteRepo.getAll(categoryId: categoryId);
  }

  Future<void> addNote({
    required String title,
    required String content,
    required int categoryId,
  }) async {
    await _noteRepo.insert(
      Note(title: title, content: content, categoryId: categoryId),
    );
  }

  Future<void> updateNote(Note note) async {
    await _noteRepo.update(note);
  }

  Future<void> deleteNote(int id) async {
    await _noteRepo.delete(id);
  }

  Future<List<Category>> getCategories() {
    return _categoryRepo.getAll();
  }

  Future<void> addCategory(String name) async {
    await _categoryRepo.insert(Category(name: name));
  }
}
